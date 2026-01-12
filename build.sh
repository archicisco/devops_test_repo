#!/bin/bash
set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-devops-test-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-ghcr.io}"
GITHUB_USERNAME="${GITHUB_USERNAME:-archicisco}"

# Full image name
FULL_IMAGE_NAME="${REGISTRY}/${GITHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "======================================"
echo "Building Docker Image"
echo "======================================"
echo "Image: ${FULL_IMAGE_NAME}"
echo "======================================"

# Build the image
docker build -t "${FULL_IMAGE_NAME}" .

# Also tag as latest if a specific version tag was provided
if [ "${IMAGE_TAG}" != "latest" ]; then
    docker tag "${FULL_IMAGE_NAME}" "${REGISTRY}/${GITHUB_USERNAME}/${IMAGE_NAME}:latest"
fi

echo "======================================"
echo "Build completed successfully!"
echo "======================================"
echo "Image: ${FULL_IMAGE_NAME}"

# Optional: Run tests on the built image
if [ "${RUN_TESTS}" = "true" ]; then
    echo "======================================"
    echo "Running tests..."
    echo "======================================"
    docker run --rm "${FULL_IMAGE_NAME}" python -c "print('Container test passed!')"
fi

# Optional: Push to registry
if [ "${PUSH_IMAGE}" = "true" ]; then
    echo "======================================"
    echo "Pushing image to registry..."
    echo "======================================"
    docker push "${FULL_IMAGE_NAME}"
    
    if [ "${IMAGE_TAG}" != "latest" ]; then
        docker push "${REGISTRY}/${GITHUB_USERNAME}/${IMAGE_NAME}:latest"
    fi
    
    echo "======================================"
    echo "Push completed successfully!"
    echo "======================================"
fi

echo ""
echo "To run locally:"
echo "  docker run -p 8000:8000 ${FULL_IMAGE_NAME}"
echo ""
echo "To push manually:"
echo "  docker push ${FULL_IMAGE_NAME}"
