#!/bin/sh
kubectl apply -f k8s/db -f k8s/app --recursive

# Use Bare Metal Kubernetes Node's IP
CURRENT_IP=$(hostname -I | awk '{print $2}')

# # Append the entry to /etc/hosts
# sudo cat <<EOF >> /etc/hosts
# $CURRENT_IP www.test.com
# EOF
echo "$CURRENT_IP www.test.com" | sudo tee -a /etc/hosts

echo "Add $CURRENT_IP www.test.com to /etc/hosts"

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
