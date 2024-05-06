FROM docker.io/nginx:1.21.1-alpine
WORKDIR /usr/share/nginx/html
COPY build/web ./