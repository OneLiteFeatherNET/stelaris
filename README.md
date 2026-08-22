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

- **Install Flutter** – Ensure you have Flutter installed with the latest required version (**3.41.9**).
- **Modify the Environment Class** – Adjust the backend URL in the environment class to match your server setup.
- **Start the Backend Server** - Start the backend server
- **Run the App** – Start the application by pressing the **Start** button in your IDE or running:
  ```sh  
  flutter run  
  ```  
  
## Docker

The production image is built `FROM scratch` and contains a single file: a
static binary with the compiled web bundle embedded in it - no nginx, no shell,
no package manager.

```sh
flutter build web --release --wasm
docker build -t stelaris-ui:local .
docker run --rm -p 8080:8080 \
  -e STELARIS_BACKEND_URL=http://localhost:8081 \
  stelaris-ui:local
```

The backend URLs are **not** compiled into the image - the server serves them as
`/config.json` and the app reads them at startup, so one image runs against every
environment. `lib/env/environment.dart` still provides the values for a local
`flutter run`.

See [docs/docker-image.md](docs/docker-image.md) for configuration, response
headers and deployment notes.

## Wiki

You can find the Wiki under the following [Link](https://gitlab.onelitefeather.dev/dungeon/frontend/stelaris-ui/-/wikis/pages)

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.






