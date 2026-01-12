# DevOps Test Repository

[![CI/CD Pipeline](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/archicisco/devops_test_repo/actions/workflows/ci-cd.yml)

FastAPI application with complete CI/CD pipeline and Kubernetes deployment configuration.

**✨ Latest update:** Simplified CI/CD with single-arch builds and main branch only.

## 📖 Overview

This repository contains a FastAPI-based user management application with:
- Docker containerization with multi-stage builds
- Automated CI/CD with GitHub Actions
- Kubernetes deployment (Helm chart + plain manifests)
- Security scanning with Trivy
- Complete documentation

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

## 📋 CI/CD Pipeline

The GitHub Actions pipeline automatically:
1. ✅ Builds Docker images (multi-arch: amd64/arm64)
2. ✅ Pushes to GitHub Container Registry (ghcr.io)
3. ✅ Generates build attestations
4. ✅ Scans for vulnerabilities with Trivy
5. ✅ Uploads security results to GitHub Security tab

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

---

**DevOps Technical Assessment** | FastAPI + Docker + Kubernetes + GitHub Actions
