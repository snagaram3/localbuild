.PHONY: help install start stop clean setup-kind deploy-k8s terraform-apply all

help:
	@echo "LocalBuild - Local Development Environment for Interview Prep"
	@echo ""
	@echo "Available commands:"
	@echo "  make install         - Install required tools (kind, kubectl, terraform)"
	@echo "  make start          - Start all services (LocalStack, Grafana, Prometheus, ELK)"
	@echo "  make stop           - Stop all services"
	@echo "  make setup-kind     - Create kind cluster"
	@echo "  make build-app      - Build application Docker image"
	@echo "  make deploy-k8s     - Deploy application to Kubernetes"
	@echo "  make terraform-init - Initialize Terraform"
	@echo "  make terraform-apply - Apply Terraform configurations"
	@echo "  make clean          - Remove all containers and volumes"
	@echo "  make all            - Setup everything from scratch"
	@echo "  make status         - Show status of all services"
	@echo ""

install:
	@echo "Installing required tools..."
	@command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Please install Docker first."; exit 1; }
	@command -v kind >/dev/null 2>&1 || { echo "Installing kind..."; brew install kind; }
	@command -v kubectl >/dev/null 2>&1 || { echo "Installing kubectl..."; brew install kubectl; }
	@command -v terraform >/dev/null 2>&1 || { echo "Installing terraform..."; brew install terraform; }
	@echo "All tools installed successfully!"

start:
	@echo "Starting all services..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 20
	@echo "Services started successfully!"
	@echo ""
	@echo "Access URLs:"
	@echo "  LocalStack:     http://localhost:4566"
	@echo "  Grafana:        http://localhost:3000 (admin/admin)"
	@echo "  Prometheus:     http://localhost:9090"
	@echo "  Kibana:         http://localhost:5601"
	@echo "  Elasticsearch:  http://localhost:9200"

stop:
	@echo "Stopping all services..."
	docker-compose down

setup-kind:
	@echo "Creating kind cluster..."
	kind create cluster --config kubernetes/kind-config.yaml --name localbuild-cluster
	@echo "Installing NGINX Ingress Controller..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Waiting for ingress controller..."
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s
	@echo "Kind cluster ready!"

delete-kind:
	@echo "Deleting kind cluster..."
	kind delete cluster --name localbuild-cluster

build-app:
	@echo "Building application Docker image..."
	cd app && docker build -t localbuild-app:latest .
	@echo "Loading image into kind cluster..."
	kind load docker-image localbuild-app:latest --name localbuild-cluster

deploy-k8s:
	@echo "Deploying application to Kubernetes..."
	kubectl apply -f kubernetes/namespace.yaml
	kubectl apply -f kubernetes/configmap.yaml
	kubectl apply -f kubernetes/deployment.yaml
	kubectl apply -f kubernetes/service.yaml
	kubectl apply -f kubernetes/ingress.yaml
	kubectl apply -f kubernetes/hpa.yaml
	@echo "Waiting for deployment..."
	kubectl wait --for=condition=available --timeout=300s deployment/localbuild-app -n localbuild-app || true
	@echo "Deployment complete!"
	@echo ""
	kubectl get pods -n localbuild-app

terraform-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

terraform-plan:
	@echo "Planning Terraform changes..."
	cd terraform && terraform plan

terraform-apply:
	@echo "Applying Terraform configurations to LocalStack..."
	cd terraform && terraform apply -auto-approve
	@echo "Terraform apply complete!"

terraform-destroy:
	@echo "Destroying Terraform resources..."
	cd terraform && terraform destroy -auto-approve

status:
	@echo "=== Docker Containers ==="
	@docker-compose ps
	@echo ""
	@echo "=== Kind Clusters ==="
	@kind get clusters || echo "No kind clusters found"
	@echo ""
	@echo "=== Kubernetes Pods ==="
	@kubectl get pods --all-namespaces 2>/dev/null || echo "No Kubernetes cluster available"

logs:
	@echo "Showing logs from all services..."
	docker-compose logs -f

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	kind delete cluster --name localbuild-cluster || true
	@echo "Cleanup complete!"

all: install start setup-kind build-app deploy-k8s terraform-init terraform-apply
	@echo ""
	@echo "========================================="
	@echo "LocalBuild setup complete!"
	@echo "========================================="
	@echo ""
	@echo "Access URLs:"
	@echo "  LocalStack:     http://localhost:4566"
	@echo "  Grafana:        http://localhost:3000 (admin/admin)"
	@echo "  Prometheus:     http://localhost:9090"
	@echo "  Kibana:         http://localhost:5601"
	@echo "  Application:    http://localhost:30080"
	@echo ""
