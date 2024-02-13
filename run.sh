#!/bin/sh
./gradlew DBInit clean build jib DBShutDown
kubectl apply -f db/. -f app/.
