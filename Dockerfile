FROM nginx:1.29.0-alpine
LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL stage="production"
WORKDIR /usr/share/nginx/html
COPY web ./
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
LABEL version="1.0"
LABEL description="Stelaris UI web application"