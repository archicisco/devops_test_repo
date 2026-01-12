# Deployment Guide

Simple deployment instructions for running the FastAPI application in Kubernetes.

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Helm 3.x (optional, for Helm deployment)

## Deployment Options

### Option 1: Kubernetes Manifests

**Deploy:**
```bash
kubectl apply -f k8s/
```

**Verify deployment:**
```bash
kubectl get all -n devops-test
kubectl get pvc -n devops-test
```

**Access the application:**
```bash
# Port-forward to access locally
kubectl port-forward -n devops-test svc/devops-test-app 8000:80

# Test API
curl http://localhost:8000/users/
```

**For minikube:**
```bash
# Get service URL (NodePort 30080)
minikube service devops-test-app -n devops-test --url

# Or access via minikube IP
curl http://$(minikube ip):30080/users/
```

**Cleanup:**
```bash
kubectl delete -f k8s/
```

---

### Option 2: Helm Chart

**Install:**
```bash
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --create-namespace
```

**Verify deployment:**
```bash
helm list -n devops-test
kubectl get all -n devops-test
```

**Access the application:**
```bash
# Port-forward to access locally
kubectl port-forward -n devops-test svc/devops-test-app 8000:80

# Test API
curl http://localhost:8000/users/
```

**For minikube:**
```bash
# Get service URL (NodePort 30080)
minikube service devops-test-app -n devops-test --url
```

**Upgrade:**
```bash
helm upgrade devops-test-app ./helm/devops-test-app \
  --namespace devops-test
```

**Cleanup:**
```bash
helm uninstall devops-test-app --namespace devops-test
kubectl delete namespace devops-test
```

---

## Service Ports

The application is exposed via **NodePort** service:

- **Service Port**: 80
- **Target Port**: 8000 (container)
- **NodePort**: 30080 (external access)

### Access Methods:

1. **Port-forward** (works anywhere):
   ```bash
   kubectl port-forward -n devops-test svc/devops-test-app 8000:80
   curl http://localhost:8000/users/
   ```

2. **NodePort** (on cloud/bare-metal):
   ```bash
   curl http://<node-ip>:30080/users/
   ```

3. **Minikube service** (local minikube):
   ```bash
   minikube service devops-test-app -n devops-test --url
   # Returns something like: http://127.0.0.1:xxxxx
   curl http://127.0.0.1:xxxxx/users/
   ```

---

## Quick Test

After deployment, create a test user:

```bash
# Create user
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"secret"}'

# Get all users
curl http://localhost:8000/users/

# Get specific user
curl http://localhost:8000/users/1
```

---

## Troubleshooting

### Check pod status:
```bash
kubectl get pods -n devops-test
kubectl describe pod -n devops-test <pod-name>
kubectl logs -n devops-test <pod-name>
```

### Check service:
```bash
kubectl get svc -n devops-test
kubectl describe svc -n devops-test devops-test-app
```

### Check PVC:
```bash
kubectl get pvc -n devops-test
kubectl describe pvc -n devops-test devops-test-app-pvc
```

### Image pull issues:
If pods show `ImagePullBackOff`, make the GitHub package public:
1. Go to https://github.com/archicisco?tab=packages
2. Find `devops_test_repo` package
3. Settings → Change visibility → Public

---

## Configuration

### Helm Values

Customize deployment by editing `helm/devops-test-app/values.yaml`:

```yaml
# Number of replicas
replicaCount: 2

# Image tag
image:
  tag: "latest"

# Service type
service:
  type: NodePort
  nodePort: 30080

# Resources
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Persistence
persistence:
  enabled: true
  size: 1Gi
```

Or override values during installation:
```bash
helm install devops-test-app ./helm/devops-test-app \
  --namespace devops-test \
  --create-namespace \
  --set replicaCount=3 \
  --set image.tag=v1.0.0
```

---

## CI/CD

The application is automatically built and pushed to GitHub Container Registry via GitHub Actions.

**Image location:**
```
ghcr.io/archicisco/devops_test_repo:latest
```

**Tags available:**
- `latest` - latest master branch
- `master-<sha>` - specific commit
- `v1.0.0` - version tags

To deploy a specific version:
```bash
# Helm
helm install devops-test-app ./helm/devops-test-app \
  --set image.tag=v1.0.0

# Or edit k8s/deployment.yaml and change image tag
```
