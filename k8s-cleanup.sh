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

# Define the pattern to match
PATTERN="www\.test\.com"

# Check if the system is macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SED_INPLACE_OPTION="-i ''"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    SED_INPLACE_OPTION="-i"
else
    echo "Unsupported operating system"
    exit 1
fi

# Use sed to delete the line containing the pattern
sudo sed $SED_INPLACE_OPTION "/$PATTERN/d" /etc/hosts

# Optional: Print a message indicating success
echo "Line containing $PATTERN deleted from /etc/hosts"
