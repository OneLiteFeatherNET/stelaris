# Stelaris UI

The Stelaris project is primarily aimed at facilitating the creation of various models, which are
subsequently translated into programming code. Model creation is facilitated through a user
interface (UI) developed using Flutter. Within this UI, a variety of widgets are available to aid in
model creation. Each model can be customized with different data, depending on its specific context.
Models that can be created are items, fonts, attributes and notifications. Each model has its 
own page within the UI, where the user can create, edit, and delete models. The sides 
may be divided into multiple parts. In the build page the user can generate the code.

## How to run the App on your computer

To run the application on your local computer, follow these steps:

- **Install Flutter** – Ensure you have Flutter installed with the latest required version (**3.47.1**).
- **Modify the Environment Class** – Adjust the backend URL in the environment class to match your server setup.
- **Start the Backend Server** - Start the backend server
- **Run the App** – Start the application by pressing the **Start** button in your IDE or running:
  ```sh  
  flutter run  
  ```  
  
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

The image is environment-agnostic: it is built once and promoted from staging
to production. The backend it talks to comes from `config.json`, which the app
fetches at startup and the deployment mounts over `/etc/nginx/runtime` — a
Secret in Kubernetes. Without a mount the image serves an empty configuration
and the app falls back to the values compiled in from `lib/env/environment.dart`.

```sh
# a local backend, without a cluster
printf '{"backendUrl":"http://localhost:8081","generatorUrl":"http://localhost:8082"}' > /tmp/config.json
docker run --rm -p 8080:8080 \
  -v /tmp/config.json:/etc/nginx/runtime/config.json:ro \
  stelaris-ui:local
```

The full picture — what the nginx config turns off and why, the CSP, caching,
health checks and how the image is published to Harbor — is in
[docs/docker-image.md](docs/docker-image.md).

## Wiki

You can find the Wiki under the following [Link](https://gitlab.onelitefeather.dev/dungeon/frontend/stelaris-ui/-/wikis/pages)

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.






