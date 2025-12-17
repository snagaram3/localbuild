#!/bin/bash

set -e

echo "========================================="
echo "LocalBuild - Complete Setup"
echo "========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: Please run this script from the localbuild directory"
    exit 1
fi

echo "Step 1/6: Starting Docker services..."
docker-compose up -d
echo "Waiting for services to be ready..."
sleep 30

echo ""
echo "Step 2/6: Creating kind cluster..."
if kind get clusters | grep -q "localbuild-cluster"; then
    echo "Cluster already exists, skipping..."
else
    kind create cluster --config kubernetes/kind-config.yaml --name localbuild-cluster
    echo "Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s || true
fi

echo ""
echo "Step 3/6: Installing app dependencies..."
cd app
npm install
cd ..

echo ""
echo "Step 4/6: Building and loading Docker image..."
cd app
docker build -t localbuild-app:latest .
cd ..
kind load docker-image localbuild-app:latest --name localbuild-cluster

echo ""
echo "Step 5/6: Deploying to Kubernetes..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml

echo "Waiting for deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/localbuild-app -n localbuild-app || true

echo ""
echo "Step 6/6: Applying Terraform configuration..."
cd terraform
terraform init
terraform apply -auto-approve || echo "Terraform apply failed, but continuing..."
cd ..

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Access URLs:"
echo "  LocalStack:     http://localhost:4566"
echo "  Grafana:        http://localhost:3000 (admin/admin)"
echo "  Prometheus:     http://localhost:9090"
echo "  Kibana:         http://localhost:5601"
echo "  Elasticsearch:  http://localhost:9200"
echo "  Application:    http://localhost:30080"
echo ""
echo "Kubernetes Pods:"
kubectl get pods -n localbuild-app
echo ""
echo "To view logs: make logs"
echo "To check status: make status"
echo "To clean up: make clean"
echo ""
