FROM nginx:1.31.4-alpine
LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL stage="production"
WORKDIR /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web ./
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
LABEL version="1.0"
LABEL description="Stelaris UI web application"