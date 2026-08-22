# The Stelaris UI container image

The production image is built `FROM scratch` and contains **one file**: a
statically linked Go binary with the compiled Flutter web bundle embedded in it.

```
$ docker export $(docker create stelaris-ui) | tar -t
stelaris-ui
```

No nginx, no shell, no libc, no package manager, no writable path. Nothing in
the image can be executed except the server itself, which serves `GET` and
`HEAD` for files that were baked in at build time and nothing else.

## Why not nginx

nginx is a reverse proxy, load balancer, TLS terminator, FastCGI/uwsgi gateway
and scripting host that also happens to serve static files. Stelaris UI needs
the last of those. Everything else is attack surface that has to be patched,
scanned and reasoned about for the lifetime of the project.

Measured against the image this replaces (`nginx:1.31.4-alpine`):

| | nginx:1.31.4-alpine | scratch image |
| --- | --- | --- |
| OS packages | 71 | 0 |
| Files in the image | 2130 | 1 |
| Executables in `bin`/`sbin` | 340 | 1 |
| Image size, same 45 MB bundle | 42.0 MB | 19.9 MB (precompressed copies included) |
| Shell available to an attacker | `/bin/sh` (busybox) | none |
| Runs as | root, drops to `nginx` for workers | uid 65532, never root |
| Listens on | port 80 (privileged) | port 8080 (unprivileged) |

Both images happened to report zero known CVEs at the time this was written -
the point is not today's CVE count but how much software has to stay CVE-free.
Here that is the Go standard library and ~400 lines of our own code.

### Options that were considered

| Option | Verdict |
| --- | --- |
| Keep nginx (alpine) | Works, but ships an entire proxy stack, a shell and 71 packages to serve static files. |
| Distroless (`gcr.io/distroless/static:nonroot`) plus a static server | Nearly as small, but still ships `/etc/passwd`, CA bundles and tzdata we do not use, and adds a third-party base image to the supply chain. |
| A third-party static server binary (`static-web-server`, `darkhttpd`, `thttpd`, Caddy) | Removes nginx but replaces it with another externally maintained network-facing binary, plus a config file the image has to read. |
| No server at all - an image that only carries the bundle | The smallest possible attack surface, and the right answer *if* the bundle is mounted into something else (a CDN, an ingress that serves static content, an init container that copies into a shared volume). It cannot be deployed on its own, which is how Stelaris UI is deployed today. See "Serving the bundle without any server" below. |
| **Static Go binary with the bundle embedded, on scratch** | **Chosen.** One file, zero third-party dependencies, no config file, no filesystem access at runtime. | 

### Why a Dart binary is not an option

Compiling the server in Dart would have kept the project single-language, but
`dart compile exe` links against glibc and cannot run in an image with no libc.
Go was picked because `CGO_ENABLED=0` produces a genuinely static binary and
because its standard library covers everything needed here - the server has no
third-party dependencies at all, so `go.mod` needs no `go.sum`.

### Serving the bundle without any server

If Stelaris UI ever moves behind something that serves static files itself
(a CDN, an S3-style bucket, an ingress with a static backend), the server
becomes unnecessary. The build stage already produces the bundle as plain files,
so an "artifact only" image is a two-line change - the runtime piece of this
setup is deliberately the part that is easy to delete.

## Building

The image expects a finished Flutter web build at `build/web` in the build
context:

```sh
flutter build web --release --wasm
docker build -t stelaris-ui:local .
docker run --rm -p 8080:8080 \
  -e STELARIS_BACKEND_URL=http://localhost:8081 \
  stelaris-ui:local
```

The build fails loudly if `build/web` is missing rather than shipping an image
that serves a placeholder page.

### In CI

The `flutter` job builds the bundle, assembles `Dockerfile` + `tool/webserver` +
`build/web` into a `docker-context` artifact, and hands it to the org-wide
[`docker-publish.yml`](https://github.com/OneLiteFeatherNET/workflows), which
builds the image and pushes it with **chunked blob uploads** via `regctl`.

That is not a preference: Harbor sits behind a proxy that caps request bodies at
100 MB, and a plain `docker push` sends each layer as one request. The image's
bundle layer is comfortably over that, so `docker push` fails - which is exactly
what it did here, as a `401` on the blob `HEAD` request. `regctl` splits any
blob above 50 MiB into several `PATCH` requests instead.

Image tags: a `v*.*.*` tag publishes that version; every other push publishes
`<manifest-version>-<branch-slug>` plus an immutable `sha-<short>` tag. Branch
builds are prerelease versions, so they never take over the `1`/`1.0` aliases of
a released image.

## Configuration

Everything is an environment variable - the container reads no files at runtime.

| Variable | Default | Purpose |
| --- | --- | --- |
| `STELARIS_ADDR` | `:8080` | Listen address. Unprivileged port, so no capabilities are needed. |
| `STELARIS_BACKEND_URL` | *(empty)* | Backend base URL handed to the app via `/config.json`. See "Runtime configuration". |
| `STELARIS_GENERATOR_URL` | *(empty)* | Generator service base URL, same mechanism. |
| `STELARIS_CSP` | see below | Full `Content-Security-Policy` value. Set it to an empty string to drop the header entirely. |
| `STELARIS_CONNECT_SRC` | derived from the two URLs above | `connect-src` of the default policy. Set it only when the app must reach an origin that is neither of those. Ignored when `STELARIS_CSP` is set. |
| `STELARIS_CROSS_ORIGIN_ISOLATION` | `false` | Sends COOP/COEP. See below. |
| `STELARIS_COEP` | `credentialless` | `credentialless` or `require-corp`, used only when isolation is on. |
| `STELARIS_ASSET_CACHE_CONTROL` | `no-cache` | `Cache-Control` for non-entry-point files. Entry points always revalidate. |
| `STELARIS_ACCESS_LOG` | `true` | One JSON line per request on stdout. Query strings are never logged. |

### Runtime configuration

The app needs a backend URL, and that URL differs per environment. Compiling it
into the bundle would make the image environment-specific - it could not be
built once and promoted from staging to production - so the server hands it over
at runtime instead:

```
GET /config.json
Cache-Control: no-store

{"backendUrl":"https://api.stelaris.example/v1","generatorUrl":"https://gen.stelaris.example"}
```

`lib/env/runtime_config.dart` fetches this before the first API call
(`RuntimeConfig.load()` in `main()`), and `ApiService` reads
`RuntimeConfig.current`. The rules:

- The endpoint always wins over a `config.json` that happens to be in the
  bundle, so a stale file in a build cannot override a live deployment.
- `no-store`, always. A cached configuration outlives the deployment that
  produced it and then points the app at the wrong backend.
- Any field the server leaves empty falls back to the value compiled into
  `lib/env/environment.dart`, which is what a local `flutter run` uses. A
  missing, unreachable or malformed `/config.json` is not fatal for the same
  reason - the app starts on the compiled-in defaults and the failure shows up
  in the console and in the first API call.
- `connect-src` in the default CSP is derived from these same URLs, so the
  policy cannot drift away from the configuration and quietly block the backend.

The app requests `config.json` relative to the document base href. The image
assumes a build with the default base href `/`; serving it under a sub path
needs a build with a matching `--base-href` and an ingress that does not strip
the prefix.

### Response headers

Sent on every response:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Cross-Origin-Resource-Policy: same-origin
Permissions-Policy: accelerometer=(), autoplay=(), camera=(), ...
Content-Security-Policy: <configurable>
```

The default CSP is the strictest policy a Flutter web bundle actually runs
under, not the strictest one a browser accepts:

- `'unsafe-inline'` for scripts, because `web/index.html` carries inline
  bootstrap and theme-preload scripts and Flutter's loader does not support CSP
  nonces ([flutter/flutter#167800](https://github.com/flutter/flutter/issues/167800)).
- `'unsafe-eval'` and `'wasm-unsafe-eval'`, because CanvasKit and the Wasm
  entrypoint compile code at runtime
  ([flutter/flutter#127658](https://github.com/flutter/flutter/issues/127658)).
  Building with `flutter build web --csp` would allow dropping `'unsafe-eval'`.
- `blob:` for scripts and workers, because the engine spawns its web workers
  from blob URLs.

TLS and HSTS are intentionally not handled here: the container speaks plain HTTP
and the ingress terminates TLS.

### Cross-origin isolation (COOP/COEP)

`flutter build web --wasm` renders multi-threaded only in a cross-origin
isolated context, which requires `Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: credentialless` (or `require-corp`). Without
them the engine silently falls back to the single-threaded Skwasm build - it
works, it is just slower.

It is off by default for two reasons:

1. Isolation breaks every cross-origin resource that does not opt in via CORP or
   CORS, which includes anything the backend might serve.
2. Multi-threaded Skwasm currently renders a blank page under Chrome 146 when
   isolation is on ([flutter/flutter#184843](https://github.com/flutter/flutter/issues/184843),
   open at the time of writing).

Turn it on with `STELARIS_CROSS_ORIGIN_ISOLATION=true` once that is fixed and
verified against the deployed backend.

### Caching

Flutter does not put content hashes in its output file names - `main.dart.wasm`
keeps its name across builds - so a long `max-age` pins browsers to a build that
no longer exists on the server. The default is therefore `no-cache`, meaning
"cache it, but revalidate": every file carries a strong `ETag` derived from its
content, so revalidation costs a 304 and no body.

Entry points (`index.html`, `flutter.js`, `flutter_bootstrap.js`,
`flutter_service_worker.js`, `manifest.json`, `version.json`) always revalidate,
regardless of `STELARIS_ASSET_CACHE_CONTROL`.

Text assets are gzipped once at image build time; the server picks the `.gz`
sibling when the client accepts gzip and serves it under a separate `ETag`.
Brotli would compress better but is not in the Go standard library, and a
dependency is a worse trade than a few percent of bandwidth here.

### Routing

`go_router` owns every path that is not a file, so a request that does not match
a bundle file falls back to `index.html` with a 200 - the same behaviour as
nginx's `try_files $uri $uri/ /index.html`. A request that *looks* like a file
(anything with an extension) returns an honest 404 instead, because answering it
with HTML breaks streaming Wasm instantiation and hides broken builds.

## Running it safely

The image supports every container hardening knob out of the box:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65532
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
  seccompProfile:
    type: RuntimeDefault
```

There is no writable path in the image, no temp directory the server needs and
no capability it asks for. The uid can be overridden with `--user`; nothing in
the image is owned by a particular user.

Health checks:

- Kubernetes: `GET /healthz` on the container port.
- Docker: built in - the binary health-checks itself
  (`HEALTHCHECK CMD ["/stelaris-ui", "-healthcheck"]`), because there is no
  shell or curl in the image to do it.

The server is PID 1 and handles `SIGTERM` itself, so `docker stop` and pod
termination shut it down in milliseconds instead of waiting out the grace period.
