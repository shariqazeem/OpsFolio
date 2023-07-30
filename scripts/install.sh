#!/bin/bash

cd /home/ubuntu

# Define the Docker image and container name
DOCKER_IMAGE="shariqazeem/resume:latest"
DOCKER_CONTAINER_NAME="portfolio-app-container"
DOCKER_PORT=3000

# Build the Docker image
docker build -t $DOCKER_IMAGE .

# Stop and remove the existing container, if any
docker stop $DOCKER_CONTAINER_NAME || true
docker rm $DOCKER_CONTAINER_NAME || true

# Run the Docker container on port 3000
docker run -d -p $DOCKER_PORT:3000 --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE