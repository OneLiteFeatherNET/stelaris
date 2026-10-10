# Stelaris UI

Stelaris lets you describe Minecraft content as models and turns them into
code. This repository is its web interface, built with Flutter. Every kind of
model has its own page to create, edit and delete entries, and the build page
generates the code from them.

The models you can create are **attributes**, **items**, **advancements**,
**fonts** and **sounds**.

## Running it locally

Stelaris UI is a web app, so it runs in a browser.

1. **Install Flutter.** The version the project is built with is the
   `flutter-version` in [`.github/workflows/build_pr.yml`](.github/workflows/build_pr.yml).
2. **Fetch the dependencies.** This also generates the translations:
   ```sh
   flutter pub get
   ```
3. **Start the backend** you want the app to talk to.
4. **Run the app.**
   ```sh
   flutter run -d chrome
   ```

Without further setup the app expects the backend at `http://localhost:8085`.

### Changing the backend URLs

The app reads its URLs from a `config.json` when it starts. For a local run,
create `web/config.json`:

```json
{
  "backendUrl": "http://localhost:8085",
  "generatorUrl": "http://localhost:8082"
}
```

The file is ignored by Git, so your local URLs never end up in a commit. Restart
the app after changing it. Both fields are optional. A missing or empty one
keeps its default. A deployment provides the same file, see
[Running it in a container](#running-it-in-a-container).

### Trying the sign-in locally

Without an `auth` block in `config.json` the app runs without sign-in. To try
it against a local Keycloak, run:

```sh
tool/dev_auth.sh
```

It starts Keycloak, writes a matching `web/config.json` and runs the app.
[docs/identity-provider.md](docs/identity-provider.md) explains how to connect
a real identity provider.

### Generated code

The models use [freezed](https://pub.dev/packages/freezed). The generated files
are committed, so you only need to regenerate them after changing a model:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Tests

```sh
flutter test
```

runs the whole suite on the Dart VM. Text input and keyboard handling behave
differently in a browser, so the tests for them are tagged `web` and also run
in Chrome in CI:

```sh
flutter test --platform chrome --tags web
```

Tag a test file with `@Tags(['web'])` when it drives text input or keyboard
shortcuts.

## Running it in a container

The production image builds the web bundle itself and serves it from a
hardened, unprivileged nginx, so a clean checkout is all the build needs:

```sh
docker build -t stelaris-ui:local .
docker run --rm -p 8080:8080 \
  --read-only --tmpfs /tmp \
  --cap-drop=ALL --security-opt no-new-privileges \
  stelaris-ui:local
```

The image is built once and promoted from staging to production, so it
contains no backend URLs. They come from `config.json`, which the deployment
mounts over `/etc/nginx/runtime`; in Kubernetes that is a Secret. Without a
mount the app uses its defaults.

```sh
# a local backend, without a cluster
printf '{"backendUrl":"http://localhost:8081","generatorUrl":"http://localhost:8082"}' > /tmp/config.json
docker run --rm -p 8080:8080 \
  -v /tmp/config.json:/etc/nginx/runtime/config.json:ro \
  stelaris-ui:local
```

The full picture (what the nginx config turns off and why, the CSP, caching,
health checks and how the image is published to Harbor) is in
[docs/docker-image.md](docs/docker-image.md).

## Deploying it to Kubernetes

The Helm chart in [charts/stelaris-ui](charts/stelaris-ui) is published as an
OCI artifact into the same Harbor project as the image, under `charts/`, and
its version always matches the image it deploys:

```sh
helm install stelaris-ui oci://harbor.onelitefeather.dev/onelitefeather/charts/stelaris-ui \
  --version 1.0.0 \
  --namespace stelaris --create-namespace \
  --set config.backendUrl=https://api.stelaris.example/v1 \
  --set config.generatorUrl=https://gen.stelaris.example
```

The two `--set` values become the Secret the app reads at startup. nginx serves
that file from disk per request, so changing it later takes effect without a
rollout. The chart's [README](charts/stelaris-ui/README.md) covers the ingress,
narrowing the CSP to real backend origins, and what the pod is and is not
allowed to do.

## Contributing

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/),
which CI checks; releases and the changelog are created from them. See
[CONTRIBUTING.md](CONTRIBUTING.md) for more.
