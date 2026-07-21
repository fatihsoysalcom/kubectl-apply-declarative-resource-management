#!/bin/bash

set -euo pipefail

NAMESPACE="kubectl-apply-demo"
DEPLOYMENT_NAME="nginx-declarative-app"

# Function to clean up resources
cleanup() {
    echo -e "\n--- Cleaning up resources ---"
    kubectl delete deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" --ignore-not-found=true
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
    echo "Cleanup complete."
}

# Register cleanup function to run on exit
trap cleanup EXIT

echo "--- Kubectl Apply Demonstration ---"

# 1. Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl command not found. Please install and configure kubectl."
    exit 1
fi

# 2. Create a dedicated namespace
echo -e "\n--- Creating namespace: $NAMESPACE ---"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
echo "Namespace $NAMESPACE created (or already exists)."

# 3. Define the initial Kubernetes Deployment YAML
# This YAML describes the desired state for our Nginx application.
# kubectl apply will use this to create or update the resource.
INITIAL_DEPLOYMENT_YAML=$(cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  namespace: $NAMESPACE
  labels:
    app: nginx-declarative
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-declarative
  template:
    metadata:
      labels:
        app: nginx-declarative
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6 # Initial image version
        ports:
        - containerPort: 80
EOF
)

echo -e "\n--- Applying initial Deployment ($DEPLOYMENT_NAME) ---"
echo "$INITIAL_DEPLOYMENT_YAML" | kubectl apply -f -
# The 'kubectl apply -f -' command sends the YAML from stdin to the Kubernetes API.
# It intelligently creates the resource if it doesn't exist, or updates it if it does,
# based on the declarative state defined in the YAML.

echo -e "\n--- Waiting for initial Deployment to be ready ---"
kubectl wait --for=condition=Available deployment/$DEPLOYMENT_NAME -n "$NAMESPACE" --timeout=120s

echo -e "\n--- Current Deployment status (initial) ---"
kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
kubectl get pods -l app=nginx-declarative -n "$NAMESPACE"

# 4. Define the updated Kubernetes Deployment YAML
# We're changing the image version and replica count to demonstrate an update.
UPDATED_DEPLOYMENT_YAML=$(cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  namespace: $NAMESPACE
  labels:
    app: nginx-declarative
spec:
  replicas: 3 # Increased replicas
  selector:
    matchLabels:
      app: nginx-declarative
  template:
    metadata:
      labels:
        app: nginx-declarative
    spec:
      containers:
      - name: nginx
        image: nginx:1.23.4 # Updated image version
        ports:
        - containerPort: 80
EOF
)

echo -e "\n--- Showing potential changes with 'kubectl diff' ---"
# 'kubectl diff' shows the difference between the current live state and the desired state
# specified in the YAML. This is a powerful tool for understanding what 'apply' will do.
echo "$UPDATED_DEPLOYMENT_YAML" | kubectl diff -f - || true # '|| true' to prevent script exit on diff exit code 1

echo -e "\n--- Applying updated Deployment ($DEPLOYMENT_NAME) ---"
echo "$UPDATED_DEPLOYMENT_YAML" | kubectl apply -f -
# Applying the updated YAML. kubectl apply detects the changes (image, replicas)
# and sends a patch request to the Kubernetes API to reconcile the live state
# with the new desired state. This is the core of declarative management.

echo -e "\n--- Waiting for updated Deployment to be ready ---"
kubectl wait --for=condition=Available deployment/$DEPLOYMENT_NAME -n "$NAMESPACE" --timeout=120s

echo -e "\n--- Current Deployment status (updated) ---"
kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
kubectl get pods -l app=nginx-declarative -n "$NAMESPACE"

echo -e "\n--- Demonstration complete. Resources will be cleaned up on exit. ---"
