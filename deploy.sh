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

# Function to check if Helm release exists
helm_release_exists() {
    helm list -n "$1" | grep "$2" > /dev/null 2>&1
}

echo "Builing dependencies"

cd helm && helm dependency build && cd ..

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
