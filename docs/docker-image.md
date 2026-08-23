# The Stelaris UI container image

The production image serves the compiled Flutter web bundle from a hardened,
unprivileged nginx. It is built once and promoted from staging to production:
nothing environment-specific is compiled into it, and the backend it talks to
arrives at runtime.

```sh
docker build -t stelaris-ui:local .
docker run --rm -p 8080:8080 \
  --read-only --tmpfs /tmp \
  --cap-drop=ALL --security-opt no-new-privileges \
  stelaris-ui:local
```

The build is self-contained — a clean checkout is the only input. There is no
"build the bundle first, then the image" step, and therefore no way for the two
to drift apart.

## Layout

| Path in the image | What it is |
| --- | --- |
| `/usr/share/nginx/html` | The Flutter web bundle, plus a `.gz` sibling for every text asset above 1 KiB |
| `/etc/nginx/nginx.conf` | Main config — logging, timeouts, buffers, gzip |
| `/etc/nginx/conf.d/default.conf` | The one server: routing, caching, the config endpoint |
| `/etc/nginx/snippets/security-headers.conf` | Response headers every location sends |
| `/etc/nginx/snippets/content-security-policy.conf` | The CSP alone, so a deployment can replace just that |
| `/etc/nginx/runtime/config.json` | Runtime configuration; `{}` in the image, a Secret in a cluster |

The sources for all of these live in [`docker/nginx/`](../docker/nginx).

## Why nginx, reduced

nginx is a reverse proxy, load balancer, TLS terminator and FastCGI gateway
that also serves static files. This image needs the last of those, so the
config it ships turns the rest off rather than leaving defaults in place:

- **Not root, not a privileged port.** The base image is
  `nginxinc/nginx-unprivileged`, whose master process already runs as uid 101
  and listens on 8080. The container never starts as root and never needs
  `CAP_NET_BIND_SERVICE`, so it runs fine under `--cap-drop=ALL` and a
  `runAsNonRoot` pod security context.
- **Read-only root filesystem.** Every path nginx writes to — the pid file and
  all five temp paths — lives under `/tmp`. One `tmpfs` (an `emptyDir` in
  Kubernetes) is the container's entire writable surface. Both logs go to
  stdout/stderr, so no log directory has to exist either.
- **`server_tokens off`.** No version number in `Server:` or on error pages.
- **GET and HEAD only.** Anything else is answered with 405 before it reaches a
  handler.
- **No directory listings, no dotfiles.** `autoindex off`, and any path
  containing a dot-segment returns 404 rather than confirming what is there.
- **Bounded requests.** A 1 KiB body limit, small header buffers and 10-second
  header/body timeouts. Nothing here has a use for a request body, so a
  slow-loris or an oversized-header probe runs out of budget rather than out of
  memory.
- **Relative redirects.** `absolute_redirect off` — the server always sits
  behind an ingress, and an absolute redirect would point the client at the
  pod's own host and port.

- **A fixed worker count.** `worker_processes auto` counts the host's CPUs, not
  the container's cgroup limit, so a pod with 200m CPU on a 64-core node would
  start 64 workers and pay for all of them in memory. Two is ample when the
  work is `sendfile()` on a few dozen files. The base image tunes this from its
  entrypoint, which needs to rewrite the config file and therefore cannot work
  here. Raise it via a ConfigMap if a deployment ever needs to.

The one thing the config does *not* do by default is listen on IPv6.
`listen [::]:8080` makes nginx exit at startup wherever the network namespace
has no IPv6 — a node booted with `ipv6.disable=1`, for instance — which is why
the base image only adds that line from its entrypoint after checking
`/proc/net/if_inet6`, and skips it entirely on a read-only filesystem (so with
this image it would never be added at all). A container that refuses to start
is the worse failure, so the shipped config is IPv4 only. A dual-stack
deployment adds the listener back by mounting a ConfigMap key over
`/etc/nginx/conf.d/default.conf`.

The stock config is replaced wholesale rather than layered over, so what is not
in [`docker/nginx/`](../docker/nginx) is not in the running server.

## Runtime configuration

`Environment.backendURl` in `lib/env/environment.dart` is an empty `const` with
a comment saying the pipeline should replace it — and no pipeline ever did.
Baking it in at build time would also make the image environment-specific,
which defeats building once and promoting between environments.

Instead the app fetches `config.json` in `main()`, before anything talks to an
API:

```
GET /config.json          Cache-Control: no-store
{"backendUrl":"https://api.stelaris.example/v1","generatorUrl":"https://gen.stelaris.example"}
```

nginx serves that from `/etc/nginx/runtime/config.json`, which is **outside the
document root** so a mount can replace it without touching the bundle. The
image ships `{}` there, so it runs with no mount at all.

In Kubernetes the file comes from a Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: stelaris-ui-config
stringData:
  config.json: |
    {
      "backendUrl": "https://api.stelaris.example/v1",
      "generatorUrl": "https://gen.stelaris.example"
    }
---
# in the pod spec
volumes:
  - name: runtime-config
    secret:
      secretName: stelaris-ui-config
  - name: tmp
    emptyDir:
      medium: Memory
containers:
  - name: stelaris-ui
    volumeMounts:
      - name: runtime-config
        mountPath: /etc/nginx/runtime
        readOnly: true
      - name: tmp
        mountPath: /tmp
```

That, and everything else the deployment needs, is packaged in
[`charts/stelaris-ui`](../charts/stelaris-ui) — the snippet above is what the
chart renders, shown here so the image's side of the contract is readable on its
own.

Behaviour worth knowing:

- **Never fatal.** A missing, unreachable or malformed `config.json` leaves the
  compiled-in defaults in place. Starting against the wrong backend beats not
  starting at all, and the failure is visible in the console and in the first
  failing API call.
- **Field-by-field fallback.** A blank or absent field falls back to
  `Environment`, so a half-filled configuration cannot silently point a client
  at an empty URL.
- **`no-store`.** A cached configuration outlives the deployment that produced
  it and then points the app at the wrong backend.
- **`environment.dart` is untouched** — `CONTRIBUTING.md` forbids changing it.
  It stays the source for a local `flutter run`, where nothing serves a
  configuration.

## Behaviour the config has to preserve

**Deep links.** `go_router` owns any path that does not resolve to a file, so
`try_files $uri $uri/ /index.html` serves the shell with a 200. A request that
*looks* like a file — anything with a known asset extension — still 404s, so a
broken build stays visible instead of answering a missing script with a page of
HTML and a console message about an unexpected MIME type.

**`application/wasm`.** `WebAssembly.instantiateStreaming` rejects anything
else. It comes from the base image's `mime.types`, so it holds as long as the
bundle is served by nginx at all.

**Caching.** Flutter does not content-hash its output names — `main.dart.wasm`
keeps that name across builds — so a long `max-age` would pin clients to a
build that no longer exists. Everything is served `no-cache` with the ETag
nginx derives from the file: revalidation costs a 304 and no body.
`/config.json` is `no-store`, which is stronger, and for the reason above.

**Compression.** Text assets and the Wasm modules are gzipped once at image
build time; `gzip_static` serves the `.gz` sibling at no CPU cost and falls back
to the plain file for clients that did not ask for gzip. Brotli would compress
better but is not built into the official nginx image, and adding a
third-party module to a security-baseline image is the worse trade.

## Security headers

Every location sends `X-Content-Type-Options`, `X-Frame-Options`,
`Referrer-Policy`, `Cross-Origin-Resource-Policy`, `Cross-Origin-Opener-Policy`,
`Permissions-Policy` and a CSP — all with `always`, so they survive an error
response too.

Two are deliberately absent:

- **`Strict-Transport-Security`**, because TLS terminates at the ingress, which
  is the only place that knows whether the deployment is reachable over HTTPS
  and on which hostnames. Sending HSTS from here would let a plain-HTTP dev
  deployment lock a browser out of the host. Set it on the ingress.
- **`X-XSS-Protection`**, because the header is retired and the browsers that
  still read it treat it as a bug source rather than a defence.

### The CSP

The default is the strictest policy a Flutter bundle actually runs under, not
the strictest a browser accepts. Each relaxation is one Flutter requires:

| Relaxation | Why |
| --- | --- |
| `script-src 'unsafe-inline'` | `web/index.html` bootstraps Flutter from an inline script, and Flutter's loader does not support nonces ([flutter/flutter#167800](https://github.com/flutter/flutter/issues/167800)) |
| `script-src 'unsafe-eval' 'wasm-unsafe-eval'` | CanvasKit and the Wasm entrypoint compile at runtime ([flutter/flutter#127658](https://github.com/flutter/flutter/issues/127658)) |
| `style-src 'unsafe-inline'` | The framework injects styles into the document head |
| `worker-src blob:` | Skwasm starts its render workers from blob URLs |

`connect-src` is the one directive that depends on where the image is deployed,
because it has to allow whatever `config.json` points at. The default is
`'self' https:` — the image is built once and promoted, so it cannot know those
hosts. It still blocks plain `http:`, `ws:` and `data:` as exfiltration
channels.

A deployment that knows its backends should narrow this to the exact origins by
mounting one ConfigMap key over
`/etc/nginx/snippets/content-security-policy.conf`:

```
add_header Content-Security-Policy "default-src 'self'; …; connect-src 'self' https://api.stelaris.example https://gen.stelaris.example" always;
```

**COEP is off**, so the page is not cross-origin isolated. Turning it on buys
only multi-threaded Wasm rendering, and it breaks every cross-origin resource
that does not opt in via CORP or CORS. COOP is set to
`same-origin-allow-popups` rather than `same-origin` because the app opens
external links in a new tab.

## Health checks

`GET /healthz` returns `200 ok`, is kept out of the access log, and is what
Kubernetes should probe:

```yaml
readinessProbe:
  httpGet: { path: /healthz, port: 8080 }
livenessProbe:
  httpGet: { path: /healthz, port: 8080 }
```

The image also carries a Docker `HEALTHCHECK` hitting the same path with
busybox `wget`, for `docker run` outside a cluster.

## Versions and updates

| Pin | Where | Kept current by |
| --- | --- | --- |
| Flutter SDK | `ARG FLUTTER_VERSION` in the Dockerfile, `flutter-version` in the workflows | Renovate, `flutter-version` datasource, grouped into one PR |
| nginx | The `FROM` tag of the runtime stage | Renovate, `docker` manager |
| Debian | The `FROM` tag of the build stage | Renovate, `docker` manager |

The Flutter archive is verified against the `sha256` in Google's own release
manifest for the pinned version, read at build time. Version and checksum
therefore come from one source and cannot drift apart the way a hand-copied
hash next to a version bump does.

## Publishing

The image is published on a release, from `.github/workflows/release-please.yml`.
That job is chained into the release run rather than triggered by the tag,
because release-please tags with `GITHUB_TOKEN` and such a tag starts no
`on: push: tags` workflow - and because the release is the only place that
already knows the version, so nothing has to derive one.

It delegates to the org-wide
[`docker-publish.yml`](https://github.com/OneLiteFeatherNET/workflows). Harbor
sits behind a proxy that caps request bodies at 100 MB and a plain `docker
push` sends each layer as one request, so that workflow pushes with `regctl`,
splitting blobs above 50 MiB across several `PATCH` requests. The image is
keyless-signed via GitHub OIDC and lands at
`harbor.onelitefeather.dev/onelitefeather/stelaris`, next to `otis` and
`sturnus`.

There are no per-branch images. Deploying something that is not a release means
pointing a deployment at a released tag; cutting a release is the way to get a
new image.

## What the pull-request job checks

`.github/workflows/build_pr.yml` builds the image on every pull request. It does
not push it and does not exercise it: the point is that the image builds at all,
which is what was missing when the `Dockerfile` on `develop` spent months
copying a file that had been deleted from the tree.

`nginx -t` runs inside the build, so a server configuration that does not parse
fails there rather than in a cluster.
