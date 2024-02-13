#!/bin/sh
# kubectl delete pv mysql-storage-pv mysql-config-pv
# kubectl delete pvc mysql-storage-mysql-0 mysql-config-mysql-0
kubectl delete -f k8s/db -f k8s/app -f k8s/ingress --recursive

# Function to check if a command exists
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# Check if Minikube is installed
if command_exists minikube; then
    # # Find any running Minikube tunnel processes
    # TUNNEL_PID=$(pgrep -f "minikube tunnel")
    # if [ ! -z "$TUNNEL_PID" ]; then
    #     kill $TUNNEL_PID
    #     echo "Minikube tunnel process killed."
    # else
    #     echo "No Minikube tunnel process found."
    # fi

    # Find any running kubectl proxy processes
    PROXY_PID=$(pgrep -f "kubectl proxy")
    if [ ! -z "$PROXY_PID" ]; then
        kill $PROXY_PID
        echo "Kubectl proxy process killed."
    else
        echo "No kubectl proxy process found."
    fi
else
    echo "Minikube is not installed."
fi

# # Check and delete if "www.test.com" exists in /etc/hosts
# if grep -q "www.test.com" /etc/hosts; then
#     echo "Removing line containing 'www.test.com' from /etc/hosts..."
#     sudo sed -i '/www\.test\.com/d' /etc/hosts
#     echo "Line containing 'www.test.com' removed from /etc/hosts."
# else
#     echo "'www.test.com' not found in /etc/hosts."
# fi
#!/bin/bash

# Define the pattern to match
PATTERN="www\.test\.com"

# Use sed to delete the line containing the pattern
sudo sed -i '' "/$PATTERN/d" /etc/hosts

# Optional: Print a message indicating success
echo "Line containing $PATTERN deleted from /etc/hosts"
