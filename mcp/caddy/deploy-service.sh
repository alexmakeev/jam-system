#!/bin/bash

# deploy-service.sh - Deploy service with unique domain enforcement
# Usage: ./deploy-service.sh <container-name> <domain> <port> <image>

set -e

CONTAINER_NAME="$1"
DOMAIN="$2"
PORT="$3"
IMAGE="$4"

if [ $# -ne 4 ]; then
    echo "Usage: $0 <container-name> <domain> <port> <image>"
    echo "Example: $0 my-app app.robobobr.ru 3000 my-app:latest"
    exit 1
fi

echo "🔍 Checking for domain conflicts..."

# Check if domain is already used by another container
EXISTING_CONTAINERS=$(docker ps -a --filter "label=caddy=$DOMAIN" --format "{{.Names}}" | grep -v "^$CONTAINER_NAME$" || true)

if [ -n "$EXISTING_CONTAINERS" ]; then
    echo "❌ Domain '$DOMAIN' is already used by:"
    echo "$EXISTING_CONTAINERS"
    echo ""
    echo "Options:"
    echo "1. Stop conflicting containers: docker stop $EXISTING_CONTAINERS"
    echo "2. Use a different domain"
    echo "3. Use --force flag to stop them automatically"

    if [ "$5" == "--force" ]; then
        echo "🔄 Force flag detected. Stopping conflicting containers..."
        docker stop $EXISTING_CONTAINERS
        docker rm $EXISTING_CONTAINERS
        echo "✅ Conflicting containers removed"
    else
        exit 1
    fi
fi

echo "🚀 Deploying $CONTAINER_NAME..."

# Stop and remove existing container with same name
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Deploy new container
docker run -d \
    --name "$CONTAINER_NAME" \
    --label "caddy=$DOMAIN" \
    --label "caddy.reverse_proxy={{upstreams $PORT}}" \
    --restart unless-stopped \
    "$IMAGE"

echo "✅ Successfully deployed $CONTAINER_NAME at https://$DOMAIN"
echo "🔍 Check status: docker ps | grep $CONTAINER_NAME"