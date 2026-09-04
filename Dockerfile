# syntax=docker/dockerfile:1

# Stelaris UI production image.
#
# Self-contained multi-stage build: `docker build .` on a clean checkout
# produces the finished image. Stage one compiles the Flutter web bundle,
# stage two serves it from a hardened, unprivileged nginx.
#
# nginx here is deliberately reduced to what this app needs - static files over
# HTTP - and nothing else: no proxying, no scripting, no directory listings, no
# writable path, no root process and no privileged port.

# ---------------------------------------------------------------------------
# Stage 1: build the Flutter web bundle
# ---------------------------------------------------------------------------

FROM debian:13-slim AS build

# Kept in lockstep with the flutter-version in .github/workflows/*.yml and the
# `flutter:` constraint in pubspec.yaml. Renovate updates all of them together.
# renovate: datasource=flutter-version depName=flutter versioning=semver
ARG FLUTTER_VERSION=3.47.2

ENV DEBIAN_FRONTEND=noninteractive

# Only what the Flutter toolchain itself shells out to. No Chrome: this stage
# builds the web bundle, it does not run browser tests.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Flutter refuses to run some commands as root, and a non-root build is one
# less way for a compromised dependency's build hook to matter.
RUN useradd --create-home --shell /bin/bash builder

# The archive name and its checksum both come out of the release manifest for
# the pinned version, so the two cannot drift apart the way a hand-copied hash
# next to a version bump does. TLS alone would not catch a corrupted object in
# the bucket; this does.
RUN set -eu; \
    base="https://storage.googleapis.com/flutter_infra_release/releases"; \
    curl -fsSL -o /tmp/releases.json "${base}/releases_linux.json"; \
    archive="$(jq -er --arg v "$FLUTTER_VERSION" \
        'first(.releases[] | select(.version == $v and .channel == "stable")) | .archive' \
        /tmp/releases.json)"; \
    sha="$(jq -er --arg v "$FLUTTER_VERSION" \
        'first(.releases[] | select(.version == $v and .channel == "stable")) | .sha256' \
        /tmp/releases.json)"; \
    echo "Flutter ${FLUTTER_VERSION}: ${archive} (sha256 ${sha})"; \
    curl -fsSL -o /tmp/flutter.tar.xz "${base}/${archive}"; \
    echo "${sha}  /tmp/flutter.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/flutter.tar.xz -C /opt; \
    rm /tmp/flutter.tar.xz /tmp/releases.json; \
    chown -R builder:builder /opt/flutter

# Created here rather than left to WORKDIR, which makes the directory root-owned
# even after USER - and then `pub get` cannot write .dart_tool into it.
RUN install -d -o builder -g builder /home/builder/app

USER builder
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}" \
    PUB_CACHE="/home/builder/.pub-cache"
WORKDIR /home/builder/app

# Fail here rather than minutes into the build if the extracted SDK is not the
# pinned one, and warm the SDK's own caches in a layer that only a version bump
# invalidates.
# `flutter --version` is written to a file rather than piped into grep: grep -q
# closes the pipe on its first match, and the SIGPIPE that follows makes the
# Flutter tool dump a stack trace over an otherwise clean build log.
RUN flutter --version > /tmp/flutter-version.txt \
    && grep -q "Flutter ${FLUTTER_VERSION}" /tmp/flutter-version.txt \
    && rm /tmp/flutter-version.txt \
    && flutter config --enable-web \
    && flutter precache --web

# Dependencies resolve from the lockfile alone, so this layer survives every
# change that does not touch it.
COPY --chown=builder:builder pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY --chown=builder:builder . .

# The repository carries some generated sources and leaves others to the build,
# so the generator runs here the same way it runs in CI.
RUN dart run build_runner build --delete-conflicting-outputs

# --no-web-resources-cdn, because `--web-resources-cdn` defaults to on: the
# build writes the CanvasKit and Skwasm files into the bundle either way, but
# the loader then fetches them from www.gstatic.com at runtime and the copies in
# the image are never touched. That puts a third-party host on the critical path
# of an image whose whole point is not having one, and it needs a CSP wide
# enough to let a compromised dependency talk to that host too.
RUN flutter build web --release --wasm --no-web-resources-cdn

# Precompress once, here, instead of spending CPU on it for every request.
# `gzip_static` picks the .gz sibling up and falls back to the plain file for
# clients that did not ask for gzip. Files below 1 KiB are skipped because gzip
# framing tends to make those bigger.
RUN find build/web -type f \
        \( -name '*.js' -o -name '*.mjs' -o -name '*.json' -o -name '*.html' \
        -o -name '*.css' -o -name '*.svg' -o -name '*.xml' -o -name '*.txt' \
        -o -name '*.map' -o -name '*.wasm' -o -name 'NOTICES' \) \
        -size +1k -exec gzip -9 -k -f {} +


# ---------------------------------------------------------------------------
# Stage 2: serve it
# ---------------------------------------------------------------------------

# The unprivileged variant, not `nginx:alpine`: its master process already runs
# as uid 101 and listens on 8080, so the container never starts as root and
# never needs CAP_NET_BIND_SERVICE. Pinned to a full patch version because
# Renovate keeping this tag current is what keeps the image free of known CVEs.
FROM nginxinc/nginx-unprivileged:1.31.4-alpine

LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL org.opencontainers.image.title="Stelaris UI"
LABEL org.opencontainers.image.description="Stelaris UI web application served by a hardened, unprivileged nginx"
LABEL org.opencontainers.image.vendor="OneLiteFeatherNET"
LABEL org.opencontainers.image.source="https://github.com/OneLiteFeatherNET/stelaris"
LABEL org.opencontainers.image.base.name="docker.io/nginxinc/nginx-unprivileged:1.31.4-alpine"
LABEL stage="production"

USER root

# The stock config is replaced wholesale rather than layered over: what is not
# in these files is not in the running server.
RUN rm -f /etc/nginx/conf.d/*.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/conf.d/ /etc/nginx/conf.d/
COPY docker/nginx/snippets/ /etc/nginx/snippets/

# Runtime configuration the app fetches as /config.json. The image ships an
# empty object so it runs with no mount at all - the app then falls back to its
# compiled-in defaults. In a cluster a Secret is mounted over this directory.
# See docs/docker-image.md.
COPY docker/nginx/runtime/ /etc/nginx/runtime/

# Emptied first: the base image's stock document root leaves a 50x.html behind
# that the bundle does not overwrite, and nothing should be served that this
# repository did not produce.
RUN rm -rf /usr/share/nginx/html && mkdir -p /usr/share/nginx/html
COPY --from=build /home/builder/app/build/web/ /usr/share/nginx/html/

# Owned by root and readable by everyone: the worker (uid 101) must never be
# able to write to anything it serves, which is also what lets the container
# run with a read-only root filesystem.
RUN chown -R root:root /usr/share/nginx/html /etc/nginx \
    && find /usr/share/nginx/html -type d -exec chmod 0755 {} + \
    && find /usr/share/nginx/html -type f -exec chmod 0644 {} + \
    && nginx -t

USER 101:101

EXPOSE 8080

# busybox wget, because the alpine image has no curl. Kubernetes probes the
# same endpoint over the network rather than using this.
HEALTHCHECK --interval=30s --timeout=3s --start-period=3s --retries=3 \
    CMD ["wget", "--quiet", "--tries=1", "--spider", "http://127.0.0.1:8080/healthz"]

# Straight to the binary: the stock entrypoint's template rendering and
# ipv6/resolver detection all want to write into /etc/nginx, which this image
# deliberately does not allow.
ENTRYPOINT ["nginx", "-g", "daemon off;"]
