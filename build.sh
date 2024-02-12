#!/bin/sh

# Function to install Java for Debian-based systems
install_java_debian() {
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
}

# Function to install Java for Red Hat-based systems
install_java_redhat() {
    sudo yum update
    sudo yum install -y java-17-openjdk-devel
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
}

# Function to install Java for macOS
install_java_macos() {
    brew update
    brew install openjdk@17
    export JAVA_HOME=$(/usr/libexec/java_home -v17)
}

# Function to install Docker for Debian-based systems
install_docker_debian() {
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Function to install Docker for Red Hat-based systems
install_docker_redhat() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Function to install Docker for macOS
install_docker_macos() {
    brew cask install docker
    open /Applications/Docker.app
}

# Function to install Docker Compose
install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Check if JAVA_HOME is set
if [ -z "$JAVA_HOME" ]; then
    echo "JAVA_HOME is not set. Installing OpenJDK 17..."

    # Detect the OS and install Java accordingly
    OS=$(uname -s)
    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                install_java_debian
            elif [ -f /etc/redhat-release ]; then
                install_java_redhat
            else
                echo "Unsupported Linux distribution"
                exit 1
            fi
            ;;
        Darwin*)
            install_java_macos
            ;;
        *)
            echo "Unsupported operating system: $OS"
            exit 1
            ;;
    esac

    echo "OpenJDK 17 installed and JAVA_HOME set."
else
    echo "JAVA_HOME is already set to $JAVA_HOME"
fi

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Installing Docker..."

    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                install_docker_debian
            elif [ -f /etc/redhat-release ]; then
                install_docker_redhat
            else
                echo "Unsupported Linux distribution for Docker installation"
                exit 1
            fi
            ;;
        Darwin*)
            install_docker_macos
            ;;
        *)
            echo "Unsupported operating system for Docker installation: $OS"
            exit 1
            ;;
    esac

    echo "Docker installed."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    install_docker_compose
    echo "Docker Compose installed."
else
    echo "Docker Compose is already installed."
fi

echo "Build App & Docker image by Gradle.."
./gradlew DBInit clean build jib DBShutDown
