#!/bin/bash
# 06-helloworld-app.sh
# Bootstrap the HelloWorld GitOps application in Argo CD
# Sets up the namespace, image pull secret, and Argo CD Application
#
# Prerequisites:
#   - Argo CD installed and accessible
#   - GHCR_PAT env var set (GitHub PAT with read:packages scope)
#   - GITHUB_USER env var set (your GitHub username)
#
# Usage:
#   GHCR_PAT=<your-pat> GITHUB_USER=jamiegunn bash 06-helloworld-app.sh

set -e

: "${GHCR_PAT:?GHCR_PAT environment variable is required}"
: "${GITHUB_USER:?GITHUB_USER environment variable is required}"

APP_NAMESPACE="dev"
GITOPS_REPO="https://github.com/${GITHUB_USER}/cluster-manifests"

echo "=== Creating app namespace ==="
microk8s kubectl create namespace $APP_NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Creating GHCR image pull secret ==="
microk8s kubectl create secret docker-registry ghcr-creds \
  --namespace $APP_NAMESPACE \
  --docker-server=ghcr.io \
  --docker-username=$GITHUB_USER \
  --docker-password=$GHCR_PAT \
  --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Creating Argo CD Application ==="
cat <<EOF | microk8s kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helloworld
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $GITOPS_REPO
    targetRevision: HEAD
    path: apps/helloworld
  destination:
    server: https://kubernetes.default.svc
    namespace: $APP_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "=== HelloWorld application registered in Argo CD ==="
echo "Argo CD will sync the app automatically from: $GITOPS_REPO"
