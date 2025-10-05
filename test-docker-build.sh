#!/bin/bash

# Test script for Railway Docker build
echo "Testing Railway Docker build locally..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Build the Docker image
echo "Building Docker image..."
docker build -f Dockerfile.railway -t doccano-railway-test .

if [ $? -eq 0 ]; then
    echo "✅ Docker build successful!"
    echo "You can now test the container with:"
    echo "docker run --rm -p 8000:8000 -e ADMIN_USERNAME=admin -e ADMIN_PASSWORD=password -e ADMIN_EMAIL=admin@example.com -e DATABASE_URL=sqlite:///db.sqlite3 doccano-railway-test"
else
    echo "❌ Docker build failed!"
    exit 1
fi