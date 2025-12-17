# LocalBuild - Interview Preparation Environment

A comprehensive local development environment for practicing DevOps, Cloud, and Platform Engineering skills. Perfect for technical interview preparation.

## Overview

This project provides a complete local infrastructure stack including:

- **LocalStack**: AWS cloud services emulator
- **Terraform**: Infrastructure as Code
- **Kind**: Local Kubernetes cluster (simulates EKS)
- **Prometheus + Grafana**: Monitoring and visualization
- **ELK Stack**: Elasticsearch, Logstash, and Kibana for logging
- **GitHub Actions**: CI/CD pipeline automation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     LocalBuild Environment                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  LocalStack  │  │   Kind K8s   │  │  Monitoring  │      │
│  │              │  │              │  │              │      │
│  │  • S3        │  │  • Pods      │  │  • Prometheus│      │
│  │  • DynamoDB  │  │  • Services  │  │  • Grafana   │      │
│  │  • Lambda    │  │  • Ingress   │  │  • Metrics   │      │
│  │  • SQS/SNS   │  │  • HPA       │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Terraform   │  │  ELK Stack   │  │   CI/CD      │      │
│  │              │  │              │  │              │      │
│  │  • Provider  │  │  • Elastic   │  │  • GitHub    │      │
│  │  • Resources │  │  • Logstash  │  │    Actions   │      │
│  │  • State     │  │  • Kibana    │  │  • Workflows │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Docker Desktop (for Mac/Windows) or Docker Engine (for Linux)
- Make (optional, for easier command execution)
- At least 8GB RAM and 20GB disk space

## Quick Start

### 1. Install Required Tools

```bash
make install
```

This will install:
- kind (Kubernetes in Docker)
- kubectl (Kubernetes CLI)
- terraform (Infrastructure as Code)

### 2. Start All Services

```bash
make start
```

This starts:
- LocalStack (AWS emulator)
- Prometheus (metrics collection)
- Grafana (monitoring dashboards)
- Elasticsearch (log storage)
- Logstash (log processing)
- Kibana (log visualization)

### 3. Create Kubernetes Cluster

```bash
make setup-kind
```

### 4. Build and Deploy Application

```bash
make build-app
make deploy-k8s
```

### 5. Apply Terraform Configuration

```bash
make terraform-init
make terraform-apply
```

### All-in-One Setup

```bash
make all
```

## Access Points

After setup, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| LocalStack | http://localhost:4566 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| Kibana | http://localhost:5601 | - |
| Elasticsearch | http://localhost:9200 | - |
| Sample App | http://localhost:30080 | - |

## Project Structure

```
localbuild/
├── app/                    # Sample Node.js application
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── kubernetes/             # Kubernetes manifests
│   ├── kind-config.yaml
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   └── hpa.yaml
├── terraform/              # Terraform configurations
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── lambda/
├── monitoring/             # Monitoring configurations
│   ├── prometheus.yml
│   └── grafana/
├── logging/                # Logging configurations
│   └── logstash/
├── localstack/             # LocalStack setup
│   └── init/
├── ci-cd/                  # CI/CD configurations
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
├── docker-compose.yml
├── Makefile
└── README.md
```

## Interview Preparation Topics

### 1. Kubernetes (EKS Simulation)

Practice:
- Deploying applications with Deployments
- Creating Services (ClusterIP, NodePort, LoadBalancer)
- Configuring Ingress controllers
- Setting up HorizontalPodAutoscaler
- Managing ConfigMaps and Secrets
- Working with Namespaces

Commands:
```bash
kubectl get pods -n localbuild-app
kubectl describe deployment localbuild-app -n localbuild-app
kubectl logs -f deployment/localbuild-app -n localbuild-app
kubectl scale deployment localbuild-app --replicas=5 -n localbuild-app
```

### 2. Terraform & Infrastructure as Code

Practice:
- Writing Terraform configurations
- Managing state files
- Creating AWS resources (via LocalStack)
- Working with modules
- Understanding providers and backends

Commands:
```bash
cd terraform
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

### 3. AWS Services (via LocalStack)

Practice:
- S3 bucket operations
- DynamoDB table management
- Lambda function deployment
- SQS/SNS messaging
- IAM roles and policies

Commands:
```bash
# Using awslocal (LocalStack AWS CLI)
awslocal s3 ls
awslocal s3 cp test.txt s3://app-data-bucket/
awslocal dynamodb scan --table-name users
awslocal lambda list-functions
awslocal sqs send-message --queue-url <url> --message-body "test"
```

### 4. Monitoring with Prometheus & Grafana

Practice:
- Writing PromQL queries
- Creating Grafana dashboards
- Setting up alerts
- Monitoring Kubernetes metrics
- Application instrumentation

Access Grafana at http://localhost:3000 and create dashboards for:
- Container CPU/Memory usage
- Application response times
- HTTP request rates
- Error rates

### 5. Logging with ELK Stack

Practice:
- Log aggregation
- Creating Kibana visualizations
- Writing Logstash pipelines
- Elasticsearch queries

Access Kibana at http://localhost:5601 and:
- Create index patterns
- Build visualizations
- Set up log dashboards

### 6. CI/CD with GitHub Actions

Practice:
- Writing workflow files
- Building Docker images
- Running tests
- Deploying to Kubernetes
- Terraform automation

Workflows are in `.github/workflows/`:
- `ci.yml` - Continuous Integration
- `cd.yml` - Continuous Deployment

## Common Commands

### Docker Compose
```bash
docker-compose up -d           # Start services
docker-compose down            # Stop services
docker-compose logs -f         # View logs
docker-compose ps              # Check status
```

### Kind
```bash
kind create cluster --config kubernetes/kind-config.yaml
kind load docker-image localbuild-app:latest
kind delete cluster --name localbuild-cluster
```

### Kubectl
```bash
kubectl get all -n localbuild-app
kubectl describe pod <pod-name> -n localbuild-app
kubectl logs -f <pod-name> -n localbuild-app
kubectl exec -it <pod-name> -n localbuild-app -- /bin/sh
kubectl port-forward svc/localbuild-app 8080:80 -n localbuild-app
```

### Terraform
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

## Troubleshooting

### LocalStack not responding
```bash
docker-compose restart localstack
docker-compose logs localstack
```

### Kind cluster issues
```bash
kind delete cluster --name localbuild-cluster
make setup-kind
```

### Pods not starting
```bash
kubectl get events -n localbuild-app
kubectl describe pod <pod-name> -n localbuild-app
```

### Terraform state issues
```bash
cd terraform
terraform init -reconfigure
```

## Interview Questions to Practice

### Kubernetes
1. How do you scale a deployment?
2. What's the difference between a Service and an Ingress?
3. How do you troubleshoot a pod that won't start?
4. Explain HPA and how it works
5. What are readiness and liveness probes?

### Terraform
1. What is Terraform state and why is it important?
2. How do you manage secrets in Terraform?
3. Explain the difference between `terraform plan` and `terraform apply`
4. What are Terraform modules?
5. How do you handle Terraform state locking?

### AWS/Cloud
1. Explain S3 bucket policies
2. How does DynamoDB differ from RDS?
3. What are Lambda cold starts?
4. How does SQS ensure message delivery?
5. Explain VPC networking

### Monitoring & Logging
1. What is PromQL?
2. How do you set up alerts in Prometheus?
3. Explain the ELK stack components
4. How do you optimize Elasticsearch queries?
5. What metrics would you monitor for a web application?

### CI/CD
1. Explain the difference between CI and CD
2. How do you secure secrets in CI/CD pipelines?
3. What is a Docker multi-stage build?
4. How do you implement blue-green deployments?
5. What is GitOps?

## Cleanup

To remove everything:
```bash
make clean
```

This will:
- Stop all Docker containers
- Remove all volumes
- Delete the kind cluster

## Next Steps

1. Add more complex applications
2. Implement service mesh (Istio/Linkerd)
3. Add Helm charts
4. Implement ArgoCD for GitOps
5. Add security scanning tools
6. Implement backup and restore procedures

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [ELK Stack Documentation](https://www.elastic.co/guide/)

## License

MIT

## Contributing

This is a personal interview preparation project. Feel free to fork and customize for your own use.
