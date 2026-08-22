# syntax=docker/dockerfile:1

# Stelaris UI production image.
#
# The runtime stage is FROM scratch and contains exactly one file: a statically
# linked binary with the compiled Flutter web bundle embedded in it. There is no
# nginx, no shell, no libc, no package manager and no writable path, so the only
# code that can run in this container is the server itself.
#
# The Flutter bundle is expected at build/web in the build context, produced by
#   flutter build web --release --wasm
# (the CI workflow builds it in a separate job and downloads it as an artifact).

# Pinned to a full patch version on purpose: the Go standard library is the only
# dependency this image has, so Renovate keeping this tag current is what keeps
# the image free of known CVEs.
FROM golang:1.26.7-alpine AS build

# Version string reported by /stelaris-ui -version and the startup log.
ARG VERSION=dev

WORKDIR /src

# No third-party modules: the server is standard library only, which is what
# keeps the supply chain of this image down to Go itself.
COPY tool/webserver/ ./

# The checked-in webroot/ is only a placeholder for local development; the real
# bundle replaces it wholesale so nothing from it can leak into the image.
RUN rm -rf webroot && mkdir webroot
COPY build/web/ ./webroot/

# Precompress the text-ish parts of the bundle once, here, instead of burning
# CPU on every request at runtime. Files below 1 KiB are skipped because gzip
# framing usually makes them bigger. The server picks the .gz sibling up
# automatically and falls back to the plain file for clients without gzip.
RUN find webroot -type f \
        \( -name '*.js' -o -name '*.mjs' -o -name '*.json' -o -name '*.html' \
        -o -name '*.css' -o -name '*.svg' -o -name '*.xml' -o -name '*.txt' \
        -o -name '*.map' -o -name 'NOTICES' \) \
        -size +1k -exec gzip -9 -k -f {} +

# CGO_ENABLED=0 is what makes the binary static and therefore runnable in an
# image with no libc at all. -trimpath and -buildid= keep build paths and
# non-deterministic ids out of the artifact.
ENV CGO_ENABLED=0 GOFLAGS=-mod=readonly
RUN go build -trimpath -ldflags="-s -w -buildid= -X main.version=${VERSION}" -o /out/stelaris-ui .

# Fail the build rather than shipping an image that cannot serve the app.
RUN go vet ./... && /out/stelaris-ui -version


FROM scratch

LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL org.opencontainers.image.title="Stelaris UI"
LABEL org.opencontainers.image.description="Stelaris UI web application served from a scratch image by a static Go binary"
LABEL org.opencontainers.image.vendor="OneLiteFeatherNET"
LABEL org.opencontainers.image.source="https://github.com/OneLiteFeatherNET/stelaris"
LABEL org.opencontainers.image.base.name="scratch"
LABEL stage="production"

COPY --from=build /out/stelaris-ui /stelaris-ui

# Numeric because scratch has no /etc/passwd to resolve a name against. 65532 is
# the conventional "nonroot" uid, and the server binds an unprivileged port so
# it never needs CAP_NET_BIND_SERVICE.
USER 65532:65532

EXPOSE 8080

# No shell and no curl in the image, so the binary health-checks itself.
HEALTHCHECK --interval=30s --timeout=5s --start-period=2s --retries=3 \
    CMD ["/stelaris-ui", "-healthcheck"]

ENTRYPOINT ["/stelaris-ui"]
