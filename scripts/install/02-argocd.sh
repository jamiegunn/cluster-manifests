#!/bin/bash
# 02-argocd.sh
# Install Argo CD via kubectl
# Docs: https://argo-cd.readthedocs.io/en/stable/getting_started/

set -e

NAMESPACE="argocd"

echo "=== Creating namespace ==="
microk8s kubectl create namespace $NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Installing Argo CD ==="
microk8s kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for Argo CD to be ready ==="
microk8s kubectl rollout status deployment/argocd-server -n $NAMESPACE --timeout=120s

echo "=== Get initial admin password ==="
echo "Run: microk8s kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"

echo "=== Access via port-forward ==="
echo "Run: microk8s kubectl port-forward svc/argocd-server -n argocd 8080:443"
