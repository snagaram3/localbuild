# Quick Start Guide

Get up and running with LocalBuild in 5 minutes!

## Prerequisites Check

Run these commands to verify you have the basics:

```bash
docker --version
docker-compose --version
```

If either is missing, install Docker Desktop from https://www.docker.com/products/docker-desktop

## Step-by-Step Setup

### 1. Install Tools (1 minute)

```bash
make install
```

This installs kind, kubectl, and verifies terraform is available.

### 2. Start Infrastructure Services (2 minutes)

```bash
make start
```

Wait for the services to start. You should see:
- LocalStack
- Prometheus
- Grafana
- Elasticsearch
- Kibana
- Logstash

### 3. Verify Services

Open these URLs in your browser:

- Grafana: http://localhost:3000 (login: admin/admin)
- Prometheus: http://localhost:9090
- Kibana: http://localhost:5601

### 4. Create Kubernetes Cluster (2 minutes)

```bash
make setup-kind
```

This creates a local Kubernetes cluster using kind.

### 5. Deploy Application

```bash
# Build the Docker image
cd app
npm install  # Install dependencies first
cd ..

# Build and deploy
make build-app
make deploy-k8s
```

### 6. Apply Terraform Configuration

```bash
make terraform-init
make terraform-apply
```

This creates AWS resources in LocalStack:
- S3 buckets
- DynamoDB tables
- Lambda functions
- SQS queues
- SNS topics

## Verification

### Check Docker Services

```bash
docker-compose ps
```

All services should be "Up".

### Check Kubernetes

```bash
kubectl get pods -n localbuild-app
```

You should see 3 running pods.

### Check Application

```bash
curl http://localhost:30080
```

You should get a JSON response from the application.

### Check LocalStack

```bash
# Install awslocal if not already installed
pip install awscli-local

# List S3 buckets
awslocal s3 ls

# List DynamoDB tables
awslocal dynamodb list-tables
```

### Check Terraform

```bash
cd terraform
terraform output
```

You should see the created resources.

## Quick Commands Reference

```bash
# View all service status
make status

# View logs
make logs

# Stop everything
make stop

# Start everything again
make start

# Clean up everything
make clean
```

## What to Practice

### 1. Kubernetes Basics (30 minutes)

```bash
# Scale the deployment
kubectl scale deployment localbuild-app --replicas=5 -n localbuild-app

# View logs
kubectl logs -f deployment/localbuild-app -n localbuild-app

# Execute into a pod
kubectl exec -it <pod-name> -n localbuild-app -- /bin/sh

# Port forward to a pod
kubectl port-forward deployment/localbuild-app 8080:3000 -n localbuild-app
```

### 2. Terraform Practice (20 minutes)

```bash
cd terraform

# View the plan
terraform plan

# Modify main.tf to add a new resource
# Then apply
terraform apply

# Check what's in the state
terraform state list

# View outputs
terraform output
```

### 3. AWS Services via LocalStack (20 minutes)

```bash
# S3 operations
echo "test" > test.txt
awslocal s3 cp test.txt s3://app-data-bucket/
awslocal s3 ls s3://app-data-bucket/

# DynamoDB operations
awslocal dynamodb scan --table-name users

# Lambda operations
awslocal lambda list-functions
awslocal lambda invoke --function-name example_function output.txt
cat output.txt

# SQS operations
awslocal sqs send-message --queue-url <queue-url> --message-body "Hello World"
awslocal sqs receive-message --queue-url <queue-url>
```

### 4. Monitoring with Grafana (15 minutes)

1. Open http://localhost:3000
2. Login with admin/admin
3. Go to "Explore" and select Prometheus
4. Try these queries:
   ```
   rate(http_requests_total[5m])
   container_cpu_usage_seconds_total
   container_memory_usage_bytes
   ```
5. Create a dashboard with these metrics

### 5. Logging with Kibana (15 minutes)

1. Open http://localhost:5601
2. Create an index pattern for `logs-*`
3. View logs in Discover
4. Create visualizations
5. Build a dashboard

## Troubleshooting

### Services won't start

```bash
# Check Docker is running
docker ps

# Restart services
make stop
make start
```

### Kind cluster won't create

```bash
# Delete existing cluster
kind delete cluster --name localbuild-cluster

# Create again
make setup-kind
```

### Terraform errors

```bash
# Make sure LocalStack is running
docker-compose ps localstack

# Reinitialize
cd terraform
rm -rf .terraform
terraform init
```

### Pods not starting

```bash
# Check events
kubectl get events -n localbuild-app --sort-by='.lastTimestamp'

# Describe the pod
kubectl describe pod <pod-name> -n localbuild-app

# Check if image is loaded
docker images | grep localbuild-app
```

## Next Steps

Once everything is running:

1. Explore the Grafana dashboards
2. Generate some load on the application and watch metrics
3. Modify the Terraform code to add new resources
4. Try scaling the Kubernetes deployment
5. Experiment with different Kubernetes features
6. Set up alerts in Prometheus
7. Create custom Kibana dashboards

## Getting Help

- Check the main README.md for detailed documentation
- Review the Makefile for all available commands
- Inspect the docker-compose.yml for service configurations
- Look at the Kubernetes manifests in the kubernetes/ directory
- Review Terraform files in the terraform/ directory

## Clean Up

When you're done practicing:

```bash
make clean
```

This removes everything and frees up resources.

To start fresh next time, just run:

```bash
make all
```
