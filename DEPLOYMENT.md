# DevOps Test Application - Deployment Guide

FastAPI application containerized and ready for Kubernetes deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building the Image](#building-the-image)
- [Deployment Options](#deployment-options)
  - [Option 1: Using Helm](#option-1-using-helm-recommended)
  - [Option 2: Using Kubernetes Manifests](#option-2-using-kubernetes-manifests)
- [CI/CD Pipeline](#cicd-pipeline)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This is a FastAPI application with SQLite database, containerized using Docker and deployed to Kubernetes. The application provides a REST API for user management.

### Features:
- ✅ Multi-stage Docker build for optimized image size
- ✅ Non-root user for security
- ✅ Health checks configured
- ✅ Persistent storage for SQLite database
- ✅ Horizontal Pod Autoscaling support
- ✅ GitHub Actions CI/CD pipeline
- ✅ Security scanning with Trivy
- ✅ Both Helm and plain Kubernetes manifests

## 📦 Prerequisites

- Docker (for local testing)
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Helm 3.x (optional, for Helm deployment)
- GitHub account (for CI/CD)

## 🚀 Quick Start

### 1. Pull the pre-built image:
```bash
docker pull ghcr.io/archicisco/devops_test_repo:latest
```

### 2. Run locally:
```bash
docker run -p 8000:8000 ghcr.io/archicisco/devops_test_repo:latest
```

### 3. Test the API:
```bash
curl http://localhost:8000/users/
```

## 🔨 Building the Image

### Using the build script (recommended):
```bash
# Build only
./build.sh

# Build with custom tag
IMAGE_TAG=v1.0.0 ./build.sh

# Build and push to registry
PUSH_IMAGE=true ./build.sh

# Build with tests
RUN_TESTS=true ./build.sh
```

### Using Docker directly:
```bash
docker build -t ghcr.io/archicisco/devops_test_repo:latest .
docker push ghcr.io/archicisco/devops_test_repo:latest
```

## 🎮 Deployment Options

### Option 1: Using Helm (Recommended)

#### Install the application:
```bash
# Create namespace
kubectl create namespace devops-test

# Install with Helm
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --set image.tag=latest
```

#### Upgrade the application:
```bash
helm upgrade devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --set image.tag=v1.0.0
```

#### Uninstall:
```bash
helm uninstall devops-test-app --namespace devops-test
```

#### Custom values:
Create a `custom-values.yaml`:
```yaml
replicaCount: 3

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

Deploy with custom values:
```bash
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  -f custom-values.yaml
```

### Option 2: Using Kubernetes Manifests

#### Deploy all resources:
```bash
kubectl apply -f k8s/
```

#### Or deploy step by step:
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml  # optional
```

#### Check deployment status:
```bash
kubectl get pods -n devops-test
kubectl get svc -n devops-test
kubectl logs -n devops-test -l app=devops-test-app
```

#### Port-forward for local access:
```bash
kubectl port-forward -n devops-test svc/devops-test-app 8000:80
```

#### Clean up:
```bash
kubectl delete namespace devops-test
```

## 🔄 CI/CD Pipeline

### GitHub Actions Setup

The CI/CD pipeline automatically builds and pushes Docker images when code is pushed.

#### Enable GitHub Actions:
1. Go to your repository settings
2. Navigate to `Actions` → `General`
3. Enable `Read and write permissions` for GITHUB_TOKEN
4. Go to `Packages` settings and make sure packages are public or configure access

#### Pipeline triggers:
- Push to `main` or `master` branch
- New tags (e.g., `v1.0.0`)
- Pull requests
- Manual workflow dispatch

#### Image tags generated:
- `latest` - for main/master branch
- `v1.0.0` - for semantic version tags
- `main-abc1234` - branch name with commit SHA
- `pr-123` - for pull requests

#### View pipeline status:
```bash
# In your repository on GitHub
# Actions → CI/CD Pipeline
```

## ⚙️ Configuration

### Environment Variables

You can customize the application using environment variables in Helm values:

```yaml
env:
  - name: DATABASE_URL
    value: "sqlite:///./data/users.db"
  - name: LOG_LEVEL
    value: "info"
```

### Resource Limits

Default resource limits (can be customized in Helm values):
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Persistent Storage

By default, a 1Gi PVC is created for the SQLite database:
```yaml
persistence:
  enabled: true
  size: 1Gi
  storageClass: ""  # uses default storage class
```

## 🔍 Monitoring & Health Checks

### Health Check Endpoints:
- Liveness: `GET /users/`
- Readiness: `GET /users/`

### Check application health:
```bash
kubectl get pods -n devops-test
kubectl describe pod -n devops-test <pod-name>
kubectl logs -n devops-test <pod-name>
```

### Common Kubernetes commands:
```bash
# Get all resources
kubectl get all -n devops-test

# Describe deployment
kubectl describe deployment devops-test-app -n devops-test

# View logs (follow)
kubectl logs -f -n devops-test -l app=devops-test-app

# Execute command in pod
kubectl exec -it -n devops-test <pod-name> -- /bin/sh

# Scale deployment
kubectl scale deployment devops-test-app -n devops-test --replicas=3
```

## 🐛 Troubleshooting

### Image Pull Errors

If you get `ImagePullBackOff`:

1. **Check if image exists:**
   ```bash
   docker pull ghcr.io/archicisco/devops_test_repo:latest
   ```

2. **Make package public:**
   - Go to GitHub → Packages → devops_test_repo
   - Settings → Change visibility → Public

3. **Or create image pull secret:**
   ```bash
   kubectl create secret docker-registry ghcr-secret \
     --docker-server=ghcr.io \
     --docker-username=YOUR_GITHUB_USERNAME \
     --docker-password=YOUR_GITHUB_TOKEN \
     --namespace=devops-test
   ```

   Add to Helm values:
   ```yaml
   imagePullSecrets:
     - name: ghcr-secret
   ```

### Pod Crashes or CrashLoopBackOff

```bash
# Check pod status
kubectl describe pod -n devops-test <pod-name>

# Check logs
kubectl logs -n devops-test <pod-name>

# Check previous logs if pod restarted
kubectl logs -n devops-test <pod-name> --previous
```

### Persistent Volume Issues

```bash
# Check PVC status
kubectl get pvc -n devops-test

# Describe PVC
kubectl describe pvc devops-test-app-pvc -n devops-test

# If using minikube, ensure storage provisioner is enabled
minikube addons enable storage-provisioner
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n devops-test

# Check endpoints
kubectl get endpoints -n devops-test

# Port-forward for testing
kubectl port-forward -n devops-test svc/devops-test-app 8000:80

# Test from another pod
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://devops-test-app.devops-test.svc.cluster.local/users/
```

## 📚 API Documentation

Once deployed, access the interactive API documentation:
- Swagger UI: `http://your-host/docs`
- ReDoc: `http://your-host/redoc`

### API Endpoints:
- `GET /users/` - Get all users
- `GET /users/{user_id}` - Get user by ID
- `POST /users/` - Create new user
- `PUT /users/{user_id}` - Update user
- `DELETE /users/{user_id}` - Delete user

## 🔐 Security Best Practices Implemented

- ✅ Multi-stage builds to reduce image size
- ✅ Non-root user (UID 1000)
- ✅ Read-only root filesystem where possible
- ✅ Security context with dropped capabilities
- ✅ Trivy vulnerability scanning in CI/CD
- ✅ Image signing with attestation
- ✅ Resource limits configured
- ✅ Network policies ready (can be added)

## 📈 Scaling

### Manual Scaling:
```bash
kubectl scale deployment devops-test-app -n devops-test --replicas=5
```

### Auto-scaling (Helm):
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is part of a DevOps test assignment.

## 🙋 Support

For issues and questions:
- Check the troubleshooting section
- Review pod logs
- Check GitHub Actions logs
- Open an issue in the repository
