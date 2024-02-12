#!/bin/sh
kubectl delete -f k8s/db -f k8s/app -f k8s/ingress --recursive

