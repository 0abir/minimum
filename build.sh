#!/bin/bash

# Configuration
DOCKER_USERNAME="${1:-0abir}"
IMAGE_NAME="minimum"

echo "Building images for $DOCKER_USERNAME/$IMAGE_NAME..."

# Build Node Tag
echo "Building $DOCKER_USERNAME/$IMAGE_NAME:node..."
docker build -t "$DOCKER_USERNAME/$IMAGE_NAME:node" ./node

# Build Python Tag
echo "Building $DOCKER_USERNAME/$IMAGE_NAME:python..."
docker build -t "$DOCKER_USERNAME/$IMAGE_NAME:python" ./python

# Build Mother Docker (latest and explicit mother tag)
echo "Building $DOCKER_USERNAME/$IMAGE_NAME:latest..."
docker build -t "$DOCKER_USERNAME/$IMAGE_NAME:latest" ./latest

echo "All images built successfully."
echo "To push images to Docker Hub, run:"
echo "  docker push $DOCKER_USERNAME/$IMAGE_NAME:node"
echo "  docker push $DOCKER_USERNAME/$IMAGE_NAME:python"
echo "  docker push $DOCKER_USERNAME/$IMAGE_NAME:latest"
