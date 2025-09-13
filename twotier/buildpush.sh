#!/bin/bash
set -e

echo "🔧 Building all images..."
## TESTING
docker compose -f docker-compose.runtime.yml up

## PUBLISING
docker compose -f docker-compose.build.yml build
docker compose -f docker-compose.build.yml push

echo "🔐 Logging in to Docker Hub..."
docker login

echo "📤 Pushing images to docker.io/contosorealtime..."
docker compose push

echo "✅ Done."
