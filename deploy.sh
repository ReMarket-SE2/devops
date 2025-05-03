#!/bin/bash

set -e  # Exit on any error

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file is missing, app may fail to start"
fi

ENV=${1:-dev}

# Define namespaces
NAMESPACE_INGRESS="ingress-nginx"
NAMESPACE_APP="remarket"

# Define Helm Chart names
NGINX_RELEASE="nginx-ingress"
APP_RELEASE="remarket"

# Define Helm Chart repositories
NGINX_REPO="https://kubernetes.github.io/ingress-nginx"

HELM_VALUES="./environments/${ENV}.yaml"

echo "Builing dependencies"

cd helm && helm dependency build && cd ..

echo "Installing cert-manager CRDs..."
helm upgrade \
  --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true

echo "Deploying application..."

helm upgrade \
    --install \
    $APP_RELEASE \
    ./helm \
    --namespace $NAMESPACE_APP \
    --create-namespace \
    -f "$HELM_VALUES" \
    --set webapp.containers.env.google_client_id="$GOOGLE_CLIENT_ID" \
    --set webapp.containers.env.google_client_secret="$GOOGLE_CLIENT_SECRET"


# Step 2: Get Ingress details
echo "Checking Ingress..."
kubectl get ingress -n $NAMESPACE_APP

echo "Deployment complete!"
