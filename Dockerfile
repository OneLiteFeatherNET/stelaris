# Stage 1: Build the Flutter web app
FROM cirrusci/flutter:latest AS builder
LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL stage="builder"
WORKDIR /app
# Kopiere den Code in den Container
COPY . .
RUN flutter channel master
RUN flutter config --enable-web
RUN flutter doctor
RUN flutter --version
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
# Baue die Web-Version (im Release-Modus für kleinere, optimierte Assets)
RUN flutter build web --release
# Stage 2: Serve the web app with NGINX
FROM nginx:alpine
LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL stage="production"
# Kopiere die gebaute Anwendung in das Verzeichnis, das NGINX bereitstellt
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
LABEL version="1.0"
LABEL description="Stelaris UI web application"