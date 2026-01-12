# DevOps Test Repository

[![CI/CD Pipeline](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml)

FastAPI application with complete CI/CD pipeline and Kubernetes deployment configuration.

## 📖 Overview

This repository contains a FastAPI-based user management application with:
- Docker containerization
- Automated CI/CD with GitHub Actions
- Kubernetes deployment (Helm + manifests)
- Security best practices
- Complete documentation

## 🚀 Quick Start

### Run locally with Docker:
```bash
docker pull ghcr.io/archicisco/devops_test_repo:latest
docker run -p 8000:8000 ghcr.io/archicisco/devops_test_repo:latest
```

Access the API at http://localhost:8000/docs

### Deploy to Kubernetes:
```bash
# Using the deploy script
./deploy.sh

# Or manually with Helm
helm install devops-test-app ./helm/devops-test-app --namespace devops-test --create-namespace
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
│       └── ci-cd.yml      # GitHub Actions pipeline
├── helm/
│   └── devops-test-app/   # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/     # Kubernetes templates
├── k8s/                   # Plain Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── pvc.yaml
├── Dockerfile             # Multi-stage Docker build
├── .dockerignore          # Docker build exclusions
├── build.sh              # Build script
├── deploy.sh             # Deployment script
├── requirements.txt       # Python dependencies
├── main.py               # FastAPI application
└── DEPLOYMENT.md         # Detailed deployment guide
```

## 🔨 Building

### Using the build script:
```bash
# Build image
./build.sh

# Build with custom tag
IMAGE_TAG=v1.0.0 ./build.sh

# Build and push
PUSH_IMAGE=true ./build.sh
```

### Manual build:
```bash
docker build -t ghcr.io/archicisco/devops_test_repo:latest .
docker push ghcr.io/archicisco/devops_test_repo:latest
```

## 🎮 Deployment

### Option 1: Automated Script
```bash
# Deploy with Helm (default)
./deploy.sh

# Deploy with Kubernetes manifests
DEPLOYMENT_TYPE=k8s ./deploy.sh

# Deploy specific version
IMAGE_TAG=v1.0.0 ./deploy.sh
```

### Option 2: Helm
```bash
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --create-namespace \
  --set image.tag=latest
```

### Option 3: Kubernetes Manifests
```bash
kubectl apply -f k8s/
```

## 📋 CI/CD Pipeline

The GitHub Actions pipeline automatically:
1. ✅ Builds Docker images
2. ✅ Pushes to GitHub Container Registry (ghcr.io)
3. ✅ Scans for vulnerabilities with Trivy
4. ✅ Creates multi-arch images (amd64/arm64)
5. ✅ Generates build attestations

### Triggers:
- Push to `main`/`master` branch
- New version tags (e.g., `v1.0.0`)
- Pull requests
- Manual workflow dispatch

### Image Tags:
- `latest` - main branch
- `v1.0.0` - version tags
- `main-abc1234` - branch + commit SHA
- `pr-123` - pull requests

## 🔐 Security Features

- ✅ Multi-stage builds for minimal image size
- ✅ Non-root user (UID 1000)
- ✅ Security context with dropped capabilities
- ✅ Vulnerability scanning (Trivy)
- ✅ Read-only root filesystem support
- ✅ Resource limits configured
- ✅ Health checks implemented

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

## 🛠️ Development

### Local Development:
```bash
# Install dependencies
pip install -r requirements.txt

# Run application
uvicorn main:app --reload

# Access at http://localhost:8000
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
```

## 📚 Documentation

- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment guide with troubleshooting
- **API Docs**: Available at `/docs` when running
- **Helm Chart**: See `helm/devops-test-app/README.md` (if created)

## 🔍 Monitoring

### Check deployment status:
```bash
kubectl get pods -n devops-test
kubectl get svc -n devops-test
```

### View logs:
```bash
kubectl logs -n devops-test -l app=devops-test-app -f
```

### Port-forward for local access:
```bash
kubectl port-forward -n devops-test svc/devops-test-app 8000:80
```

## 🐛 Troubleshooting

Common issues and solutions are documented in [DEPLOYMENT.md](./DEPLOYMENT.md#-troubleshooting).

Quick checks:
```bash
# Check pod status
kubectl describe pod -n devops-test <pod-name>

# Check logs
kubectl logs -n devops-test <pod-name>

# Check service
kubectl get svc -n devops-test
```

## 📈 Scaling

### Manual scaling:
```bash
kubectl scale deployment devops-test-app -n devops-test --replicas=5
```

### Auto-scaling (via Helm):
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## 🧪 Testing in Kubernetes

### Using minikube:
```bash
# Start minikube
minikube start

# Deploy application
./deploy.sh

# Access via minikube
minikube service devops-test-app -n devops-test
```

### Using kind:
```bash
# Create cluster
kind create cluster

# Load image (if built locally)
kind load docker-image ghcr.io/archicisco/devops_test_repo:latest

# Deploy
./deploy.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 Requirements Checklist

- ✅ **Dockerfile** - Multi-stage build with best practices
- ✅ **Build Pipeline** - GitHub Actions with multi-arch support
- ✅ **Kubernetes Deployment** - Both Helm and manifests provided
- ✅ **Documentation** - Complete deployment and troubleshooting guide
- ✅ **Security** - Vulnerability scanning, non-root user, security context
- ✅ **CI/CD** - Automated build, test, and push
- ✅ **Monitoring** - Health checks and readiness probes

## 📄 License

This project is part of a DevOps technical assessment.

## 🙋 Support

For questions or issues:
- Check [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed guides
- Review GitHub Actions logs for CI/CD issues
- Check Kubernetes pod logs for runtime issues
- Open an issue in this repository

---

**Made with ❤️ for the DevOps Assessment**
