#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${NAMESPACE:-devops-test}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DEPLOYMENT_TYPE="${DEPLOYMENT_TYPE:-helm}"  # helm or k8s

echo -e "${GREEN}======================================"
echo "DevOps Test App - Deployment Script"
echo "======================================${NC}"
echo ""
echo "Configuration:"
echo "  Namespace: ${NAMESPACE}"
echo "  Image Tag: ${IMAGE_TAG}"
echo "  Deployment Type: ${DEPLOYMENT_TYPE}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Kubernetes cluster is accessible${NC}"
echo ""

# Function to deploy with Helm
deploy_helm() {
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}Error: Helm is not installed${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Deploying with Helm...${NC}"
    
    # Check if release exists
    if helm list -n "${NAMESPACE}" | grep -q "devops-test-app"; then
        echo "Upgrading existing release..."
        helm upgrade devops-test-app ./helm/devops-test-app \
            --namespace "${NAMESPACE}" \
            --set image.tag="${IMAGE_TAG}" \
            --wait
    else
        echo "Installing new release..."
        kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
        helm install devops-test-app ./helm/devops-test-app \
            --namespace "${NAMESPACE}" \
            --set image.tag="${IMAGE_TAG}" \
            --wait
    fi
    
    echo -e "${GREEN}✓ Helm deployment completed${NC}"
}

# Function to deploy with Kubernetes manifests
deploy_k8s() {
    echo -e "${YELLOW}Deploying with Kubernetes manifests...${NC}"
    
    # Update image tag in deployment
    if [[ "${IMAGE_TAG}" != "latest" ]]; then
        sed -i.bak "s|image: ghcr.io/archicisco/devops_test_repo:.*|image: ghcr.io/archicisco/devops_test_repo:${IMAGE_TAG}|g" k8s/deployment.yaml
    fi
    
    kubectl apply -f k8s/
    
    # Restore original deployment file if modified
    if [ -f k8s/deployment.yaml.bak ]; then
        mv k8s/deployment.yaml.bak k8s/deployment.yaml
    fi
    
    echo -e "${GREEN}✓ Kubernetes deployment completed${NC}"
}

# Deploy based on type
case "${DEPLOYMENT_TYPE}" in
    helm)
        deploy_helm
        ;;
    k8s|kubernetes)
        deploy_k8s
        ;;
    *)
        echo -e "${RED}Error: Invalid deployment type. Use 'helm' or 'k8s'${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}======================================"
echo "Deployment Information"
echo "======================================${NC}"

# Wait for deployment to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod \
    -l app=devops-test-app \
    -n "${NAMESPACE}" \
    --timeout=120s || true

echo ""
echo "Deployment Status:"
kubectl get pods -n "${NAMESPACE}" -l app=devops-test-app

echo ""
echo "Service:"
kubectl get svc -n "${NAMESPACE}"

echo ""
echo -e "${GREEN}======================================"
echo "Access the Application"
echo "======================================${NC}"
echo ""
echo "Port-forward to access locally:"
echo -e "  ${YELLOW}kubectl port-forward -n ${NAMESPACE} svc/devops-test-app 8000:80${NC}"
echo ""
echo "Then access:"
echo "  http://localhost:8000/users/"
echo "  http://localhost:8000/docs"
echo ""
echo "View logs:"
echo -e "  ${YELLOW}kubectl logs -n ${NAMESPACE} -l app=devops-test-app -f${NC}"
echo ""
