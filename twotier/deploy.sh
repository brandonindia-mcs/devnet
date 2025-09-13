#!/bin/bash
set -e

. ./buildpush.sh
echo "Creating namespace..."
kubectl apply -f namespace.yaml

echo "Installing Helm chart..."
helm upgrade --install twotier-app ./chart/twotier-app --namespace twotier

echo "Running Helm test..."
helm test twotier-app --namespace twotier

echo "Deployment complete."
