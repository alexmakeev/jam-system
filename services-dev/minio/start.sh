#!/bin/bash
# MinIO S3 Service Start Script

echo "Starting MinIO S3 service..."
docker compose up -d

echo "Waiting for service to be ready..."
sleep 5

# Check if service is running
if docker compose ps | grep -q "Up"; then
    echo "MinIO S3 service is running:"
    echo "  API Endpoint: http://localhost:19000"
    echo "  Console UI: http://localhost:19001"
    echo "  Access Key: devuser"
    echo "  Secret Key: devpassword"
else
    echo "Failed to start MinIO service"
    docker compose logs
fi