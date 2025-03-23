LABEL maintainer="OneLiteFeatherNET <contact@onelitefeather.net>"
LABEL version="1.0.0"
LABEL description="Dockerfile for Stelaris UI project"

# Use the Dart SDK base image
FROM dart:stable

# Set working directory
WORKDIR /app

# Copy build artifacts
COPY build/web /app

# Install HTTP server package
RUN dart pub add shelf

# Copy the server code
COPY bin/server.dart bin/server.dart

# Expose port 8080
EXPOSE 8080

# Start the Dart server
CMD ["dart", "bin/server.dart"]