#!/bin/sh
kubectl apply -f k8s/db -f k8s/app --recursive

# get current IP
CURRENT_IP=$(hostname -I | awk '{print $1}')

# Append the entry to /etc/hosts
cat <<EOF >> /etc/hosts
$CURRENT_IP www.test.com
EOF

echo "Added $CURRENT_IP www.test.com to /etc/hosts"

kubectl apply -f k8s/ingress --recursive

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s