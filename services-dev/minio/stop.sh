#!/bin/bash
# MinIO S3 Service Stop Script

echo "Stopping MinIO S3 service..."
docker compose down

echo "MinIO S3 service stopped."