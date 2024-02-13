#!/bin/sh
kubectl apply -f k8s/db -f k8s/app --recursive

# Function to check if a command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Check if Minikube is installed
if command_exists minikube; then
    # Use Minikube's IP
    CURRENT_IP=$(minikube ip)
    # # Set proxy, tunneling for Minikube
    echo "Set proxy, tunnel for minikube"
    kubectl proxy --address 0.0.0.0 --port 30001 --accept-hosts='^*$' >/dev/null 2>&1 &
    # minikube tunnel >/dev/null 2>&1 &
else
    # Use Bare Metal Kubernetes Node's IP
    CURRENT_IP=$(hostname -I | awk '{print $2}')
fi

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

echo "Minikube tunnel starting.."
minikube tunnel
