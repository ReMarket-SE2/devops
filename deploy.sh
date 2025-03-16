#!/bin/bash

set -e  # Exit on any error

ENV=${1:-dev}

# Define namespaces
NAMESPACE_INGRESS="ingress-nginx"
NAMESPACE_APP="remarket"

# Define Helm Chart names
NGINX_RELEASE="nginx-ingress"
APP_RELEASE="remarket"

# Define Helm Chart repositories
NGINX_REPO="https://kubernetes.github.io/ingress-nginx"

HELM_VALUES="helm-${ENV}.yaml"

# Function to check if Helm release exists
helm_release_exists() {
    helm list -n "$1" | grep "$2" > /dev/null 2>&1
}

# Step 1: Add Helm repository for NGINX
echo "Adding NGINX Helm repository..."
helm repo add ingress-nginx $NGINX_REPO
helm repo update
helm dependency update ./helm

# Step 4: Deploy application using Helm
echo "Deploying application..."
helm upgrade --install $APP_RELEASE ./helm --namespace $NAMESPACE_APP --create-namespace -f "$HELM_VALUES"

# Step 5: Get Ingress details
echo "Checking Ingress..."
kubectl get ingress -n $NAMESPACE_APP

echo "Deployment complete!"
