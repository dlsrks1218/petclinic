#!/bin/sh
echo "Updating Homebrew..."
brew update

echo "Installing Minikube..."
brew install minikube

echo "Minikube installation completed."

kubectl apply -f k8s/db -f k8s/app --recursive

kubectl apply -f k8s/ingress --recursive

echo "Wait for ingress-nginx resource.."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Wait for mysql pod to be ready..."
kubectl wait --for=condition=ready pod --timeout=120s -l app=mysql

echo "Wait for petclinic pod to be ready..."
kubectl wait --for=condition=ready pod --timeout=120s -l app=petclinic

# Add www.test.com test domain for minikube tunnel
# www.test.com:NODE_PORT -> 127.0.0.1:NODE_PORT -> $(minikube ip):NODE_PORT
echo "127.0.0.1 www.test.com" | sudo tee -a /etc/hosts

echo "Set proxy for minikube"
kubectl proxy --address 0.0.0.0 --port 30001 --accept-hosts='^*$' >/dev/null 2>&1 &