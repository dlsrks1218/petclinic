#!/bin/sh
# Set up DB for local build test and Shut down when the test ends.
# Gradle App & Docker Image Build. Push the image to docker hub registry.
./gradlew DBInit clean build jib DBShutDown
kubectl apply -f k8s/db/.
kubectl apply -f k8s/app/.
