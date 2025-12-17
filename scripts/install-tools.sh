#!/bin/bash

set -e

echo "Installing LocalBuild tools..."

# Detect OS
OS="$(uname -s)"

install_kind() {
    if command -v kind &> /dev/null; then
        echo "kind is already installed"
        return
    fi

    echo "Installing kind..."
    case "$OS" in
        Darwin*)
            brew install kind
            ;;
        Linux*)
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_kubectl() {
    if command -v kubectl &> /dev/null; then
        echo "kubectl is already installed"
        return
    fi

    echo "Installing kubectl..."
    case "$OS" in
        Darwin*)
            brew install kubectl
            ;;
        Linux*)
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_terraform() {
    if command -v terraform &> /dev/null; then
        echo "terraform is already installed"
        return
    fi

    echo "Installing terraform..."
    case "$OS" in
        Darwin*)
            brew install terraform
            ;;
        Linux*)
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install terraform
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_awslocal() {
    if command -v awslocal &> /dev/null; then
        echo "awslocal is already installed"
        return
    fi

    echo "Installing awslocal..."
    pip install awscli-local || pip3 install awscli-local
}

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker Desktop first."
    echo "Visit: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Install tools
install_kind
install_kubectl
install_terraform
install_awslocal

echo ""
echo "All tools installed successfully!"
echo ""
echo "Installed versions:"
echo "  Docker:     $(docker --version)"
echo "  kind:       $(kind --version)"
echo "  kubectl:    $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "  Terraform:  $(terraform version | head -n1)"
echo "  awslocal:   $(awslocal --version 2>/dev/null || echo 'installed')"
