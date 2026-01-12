# DevOps Test Repository

[![CI/CD Pipeline](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml)

FastAPI application with complete CI/CD pipeline and Kubernetes deployment configuration.

## 📖 Overview

This repository contains a FastAPI-based user management application with:
- Docker containerization with multi-stage builds
- Automated CI/CD with GitHub Actions
- Kubernetes deployment (Helm chart + plain manifests)
- Security scanning with Trivy
- Complete documentation

## 🚀 Quick Start

### Run locally with Docker:
```bash
docker pull ghcr.io/archicisco/devops_test_repo:latest
docker run -p 8000:8000 ghcr.io/archicisco/devops_test_repo:latest
```

Access the API at http://localhost:8000/docs

### Deploy to Kubernetes:

**Option 1: Using Helm**
```bash
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --create-namespace
```

**Option 2: Using Kubernetes manifests**
```bash
kubectl apply -f k8s/
```

## 📁 Repository Structure

```
.
├── app/                    # Application code
│   ├── database.py        # Database configuration
│   ├── models.py          # SQLAlchemy models
│   └── schema.py          # Pydantic schemas
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # GitHub Actions CI/CD pipeline
├── helm/
│   └── devops-test-app/   # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/     # Kubernetes templates
├── k8s/                   # Plain Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── pvc.yaml
├── Dockerfile             # Multi-stage Docker build
├── .dockerignore          # Docker build exclusions
├── requirements.txt       # Python dependencies
├── main.py               # FastAPI application entry point
├── DEPLOYMENT.md         # Detailed deployment guide
└── README.md             # This file
```

## 🔨 Building

### Using Docker CLI:
```bash
# Build image
docker build -t ghcr.io/archicisco/devops_test_repo:latest .

# Run locally
docker run -p 8000:8000 ghcr.io/archicisco/devops_test_repo:latest
```

### Automated via GitHub Actions:
The CI/CD pipeline automatically builds and pushes images on:
- Push to `master` branch
- New version tags (e.g., `v1.0.0`)
- Pull requests
- Manual workflow dispatch

## 🎮 Deployment

### Helm Deployment
```bash
# Install
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --create-namespace

# Upgrade
helm upgrade devops-test-app ./helm/devops-test-app \
  --namespace devops-test

# Uninstall
helm uninstall devops-test-app --namespace devops-test
```

### Kubernetes Manifests Deployment
```bash
# Deploy all resources
kubectl apply -f k8s/

# Check status
kubectl get all -n devops-test

# Delete
kubectl delete -f k8s/
```

### Access the Application
```bash
# Port-forward to access locally
kubectl port-forward -n devops-test svc/devops-test-app 8000:80

# Access API
curl http://localhost:8000/users/
```

For minikube users:
```bash
# Get service URL
minikube service devops-test-app -n devops-test --url
```

## 📋 CI/CD Pipeline

The GitHub Actions pipeline automatically:
1. ✅ Builds Docker images (multi-arch: amd64/arm64)
2. ✅ Pushes to GitHub Container Registry (ghcr.io)
3. ✅ Generates build attestations
4. ✅ Scans for vulnerabilities with Trivy
5. ✅ Uploads security results to GitHub Security tab

### Image Tags Strategy:
- `latest` - latest commit on master branch
- `master-<sha>` - specific commit on master
- `v1.0.0` - semantic version tags
- `v1.0` - major.minor version tags

## 🔐 Security Features

- ✅ Multi-stage builds for minimal image size
- ✅ Non-root user (UID 1000)
- ✅ Security context with dropped capabilities
- ✅ Trivy vulnerability scanning in CI/CD
- ✅ Resource limits configured
- ✅ Liveness and readiness probes
- ✅ Persistent storage for database

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/` | Get all users |
| GET | `/users/{id}` | Get user by ID |
| POST | `/users/` | Create new user |
| PUT | `/users/{id}` | Update user |
| DELETE | `/users/{id}` | Delete user |
| GET | `/docs` | Swagger UI |
| GET | `/redoc` | ReDoc documentation |

## 🛠️ Local Development

### Setup:
```bash
# Clone repository
git clone https://github.com/archicisco/devops_test_repo.git
cd devops_test_repo

# Install dependencies
pip install -r requirements.txt

# Run application
uvicorn main:app --reload
```

### Testing the API:
```bash
# Get all users
curl http://localhost:8000/users/

# Create user
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","password":"secret"}'

# Get specific user
curl http://localhost:8000/users/1

# Update user
curl -X PUT http://localhost:8000/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com"}'

# Delete user
curl -X DELETE http://localhost:8000/users/1
```

## 🔍 Monitoring & Debugging

### Check deployment status:
```bash
# View all resources
kubectl get all -n devops-test

# Check pods
kubectl get pods -n devops-test

# View pod details
kubectl describe pod -n devops-test <pod-name>
```

### View logs:
```bash
# Stream logs from all pods
kubectl logs -n devops-test -l app=devops-test-app -f

# Logs from specific pod
kubectl logs -n devops-test <pod-name>
```

### Check persistent storage:
```bash
kubectl get pvc -n devops-test
kubectl describe pvc -n devops-test devops-test-app-pvc
```

## 🧪 Testing in Kubernetes

### Using minikube:
```bash
# Start minikube
minikube start --driver=docker

# Deploy application
kubectl apply -f k8s/

# Access via port-forward
kubectl port-forward -n devops-test svc/devops-test-app 8000:80

# Or use minikube service
minikube service devops-test-app -n devops-test
```

### Using kind:
```bash
# Create cluster
kind create cluster

# Load image (if built locally)
kind load docker-image ghcr.io/archicisco/devops_test_repo:latest

# Deploy
kubectl apply -f k8s/
```

## 📈 Helm Configuration

Key values you can customize in `helm/devops-test-app/values.yaml`:

```yaml
# Number of replicas
replicaCount: 2

# Image configuration
image:
  repository: ghcr.io/archicisco/devops_test_repo
  tag: "latest"

# Service configuration
service:
  type: NodePort
  nodePort: 30080

# Resource limits
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Persistent storage
persistence:
  enabled: true
  size: 1Gi
```

## 📚 Documentation

- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Detailed deployment guide with troubleshooting
- **[GITHUB_SETUP.md](./GITHUB_SETUP.md)** - GitHub configuration instructions (local file)
- **[QUICKSTART.md](./QUICKSTART.md)** - Quick start guide (local file)
- **API Documentation**: Available at `/docs` endpoint when application is running

## 🐛 Troubleshooting

### Image Pull Issues
```bash
# Make GitHub package public or create image pull secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=archicisco \
  --docker-password=<your-github-token> \
  --namespace=devops-test
```

### Pod Not Starting
```bash
# Check pod events
kubectl describe pod -n devops-test <pod-name>

# Check logs
kubectl logs -n devops-test <pod-name>
```

### Database Issues
```bash
# Check PVC is bound
kubectl get pvc -n devops-test

# Verify mount in pod
kubectl exec -n devops-test <pod-name> -- ls -la /app/data
```

## 📝 Requirements Checklist

- ✅ **Dockerfile** - Multi-stage build with security best practices
- ✅ **Build Pipeline** - GitHub Actions with multi-arch support (amd64/arm64)
- ✅ **Kubernetes Deployment** - Both Helm chart and plain manifests
- ✅ **Documentation** - Complete setup and deployment guides
- ✅ **Security** - Trivy scanning, non-root user, security contexts
- ✅ **CI/CD** - Automated build, scan, and publish pipeline
- ✅ **Health Checks** - Liveness and readiness probes configured

## 📄 Technical Stack

- **Application**: Python 3.11, FastAPI, SQLAlchemy, SQLite
- **Container**: Docker multi-stage builds
- **Orchestration**: Kubernetes 1.34+, Helm 3.x
- **CI/CD**: GitHub Actions
- **Registry**: GitHub Container Registry (ghcr.io)
- **Security**: Trivy vulnerability scanner

## 🙋 Support

For issues or questions:
- Check [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions
- Review [GitHub Actions logs](https://github.com/archicisco/devops_test_repo/actions) for CI/CD issues
- Check pod logs: `kubectl logs -n devops-test -l app=devops-test-app`
- Open an issue in this repository

---

**DevOps Technical Assessment** | FastAPI + Docker + Kubernetes + GitHub Actions
