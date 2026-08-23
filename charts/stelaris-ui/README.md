# stelaris-ui

The Stelaris UI web application, served by a hardened, unprivileged nginx.

The chart is published as an OCI artifact into the OneLiteFeather Harbor, under
`onelitefeather/charts/`, next to the `onelitefeather/stelaris` image it
deploys:

```sh
helm install stelaris-ui oci://harbor.onelitefeather.dev/onelitefeather/charts/stelaris-ui \
  --version 1.0.0 \
  --namespace stelaris --create-namespace \
  --set config.backendUrl=https://api.stelaris.example/v1 \
  --set config.generatorUrl=https://gen.stelaris.example
```

The chart version and the app version move together: a chart release only ever
describes the image built from the same commit, so `image.tag` defaults to the
chart's `appVersion` and normally needs no value at all.

## What it deploys

| Resource | When |
| --- | --- |
| `Deployment` | always — 2 replicas, rolling update with `maxUnavailable: 0` |
| `Service` | always — ClusterIP on port 80 → container 8080 |
| `Secret` | unless `config.existingSecret` is set |
| `ServiceAccount` | unless `serviceAccount.create=false` — no API token mounted |
| `PodDisruptionBudget` | unless disabled |
| `ConfigMap` | only if an `nginx.*` override is set |
| `Ingress` | `ingress.enabled=true` |
| `HorizontalPodAutoscaler` | `autoscaling.enabled=true` |
| `NetworkPolicy` | `networkPolicy.enabled=true` |

## Configuration reaches the app at runtime

The image is built once and promoted from staging to production, so the backend
it talks to is not compiled into the bundle. The app fetches `config.json` when
it starts; this chart puts that document in a Secret and mounts it over the
server's runtime directory:

```yaml
config:
  backendUrl: https://api.stelaris.example/v1
  generatorUrl: https://gen.stelaris.example
```

nginx serves that file from disk on every request, so **changing the Secret
takes effect without a rollout** — a browser reload is enough. That is why the
Deployment carries no checksum annotation for it.

A field left empty is left out of the document, and the app falls back to the
value compiled into the bundle for that field alone. A missing, unreachable or
malformed configuration is never fatal: the app starts on its defaults rather
than not starting.

To manage the Secret outside this chart — sealed-secrets, external-secrets, or
by hand:

```yaml
config:
  existingSecret: stelaris-ui-config
  secretKey: config.json   # the key holding the whole document
```

## Tightening the Content-Security-Policy

The image ships `connect-src 'self' https:`, because an image that is built once
and promoted cannot know which hosts it will be allowed to talk to. Naming them
turns the policy from "any HTTPS host" into "these hosts":

```yaml
nginx:
  contentSecurityPolicy: >-
    default-src 'self'; base-uri 'self'; object-src 'none';
    frame-ancestors 'none'; form-action 'none';
    script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval';
    style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:;
    font-src 'self' data:; media-src 'self' data: blob:;
    worker-src 'self' blob:; child-src 'self' blob:; manifest-src 'self';
    connect-src 'self' https://api.stelaris.example https://gen.stelaris.example
```

`'unsafe-inline'` and `'unsafe-eval'` are not optional — Flutter's loader
bootstraps from an inline script and compiles Wasm at runtime. Dropping them
gives a blank page. The reasoning is in
[`docs/docker-image.md`](../../docs/docker-image.md).

This replaces one file inside the image, so a change to it **does** roll the
pods: nginx reads its configuration only at startup.

## Replacing the server block

`nginx.serverConfig` replaces `/etc/nginx/conf.d/default.conf` wholesale. It
exists for the one thing the image cannot decide for itself — a dual-stack
cluster that needs an IPv6 listener:

```yaml
nginx:
  serverConfig: |
    # copy of docker/nginx/conf.d/default.conf, plus:
    listen [::]:8080;
```

Copy the file from the repository and edit it; anything else and the app stops
being served. A mistake here fails the readiness probe, so the rollout stops
rather than taking the running pods with it.

## Security posture

The pod runs as uid 101 with a read-only root filesystem, no capabilities, no
privilege escalation and `seccompProfile: RuntimeDefault`. `/tmp` is a 16 MiB
in-memory `emptyDir` and is the only writable path in the container — nginx's
pid file and all of its temp paths live there.

`automountServiceAccountToken: false`: the app never calls the Kubernetes API.

`Strict-Transport-Security` is **not** sent by the container, deliberately — TLS
terminates at the ingress, which is the only place that knows whether the
deployment is reachable over HTTPS and on which hostnames. Set it there:

```yaml
ingress:
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Strict-Transport-Security: max-age=31536000; includeSubDomains";
```

`networkPolicy.enabled=true` restricts ingress to the pods named in
`networkPolicy.ingressFrom` and denies all egress — the browser talks to the
backend, not this pod, so it has no egress worth allowing.

## Checking a change to the chart

Template assertions live next to the chart and run without a cluster:

```sh
helm plugin install https://github.com/helm-unittest/helm-unittest --verify=false
helm unittest charts/stelaris-ui
```

They assert on the rendered manifests directly - that the pod really is
unprivileged and read-only, that the runtime config is mounted as a directory
and not with `subPath`, that a Secret change carries no checksum annotation
while an nginx change does. Those are the properties this chart exists to get
right, and rendering and grepping never checked them reliably.

`ct lint` covers the rest, linting the chart once per file in
[`ci/`](ci) - a minimal deployment and one with everything enabled:

```sh
ct lint --config ct.yaml
```

## Verifying a release

```sh
helm test stelaris-ui --namespace stelaris
```

The test pod asserts that `/healthz` answers, the app shell is served, a deep
link reaches the shell rather than a 404, and `/config.json` returns the
document this release put there. It is the only place the running container's
behaviour is checked, so it is worth running after an install.

## Values

The annotated defaults are in [`values.yaml`](values.yaml). The ones worth
knowing about:

| Key | Default | |
| --- | --- | --- |
| `config.backendUrl` | `""` | Without it the app has nothing to talk to |
| `config.generatorUrl` | `""` | |
| `config.existingSecret` | `""` | Manage the Secret elsewhere |
| `nginx.contentSecurityPolicy` | `""` | Narrow `connect-src` to real origins |
| `nginx.serverConfig` | `""` | Replace the server block entirely |
| `image.tag` | `""` | Empty means the chart's `appVersion` |
| `replicaCount` | `2` | Ignored when `autoscaling.enabled` |
| `resources` | 20m CPU / 64Mi | Guaranteed QoS, no CPU limit |
| `ingress.enabled` | `false` | |
| `networkPolicy.enabled` | `false` | |
