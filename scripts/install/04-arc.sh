#!/bin/bash
# 04-arc.sh
# Install Actions Runner Controller (ARC) + runner scale set via Helm
# Docs: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller
#
# Prerequisites:
#   - GitHub PAT with 'repo' scope stored as GITHUB_PAT env var
#   - Set GITHUB_REPO to your repository (e.g. jamiegunn/hello-world-dotnet)
#
# Usage:
#   GITHUB_PAT=<your-pat> GITHUB_REPO=jamiegunn/hello-world-dotnet bash 04-arc.sh

set -e

: "${GITHUB_PAT:?GITHUB_PAT environment variable is required}"
: "${GITHUB_REPO:?GITHUB_REPO environment variable is required (e.g. jamiegunn/hello-world-dotnet)}"

CONTROLLER_NAMESPACE="arc-systems"
RUNNER_NAMESPACE="arc-runners"
RUNNER_SCALE_SET_NAME="arc-runner-set"

echo "=== Adding Helm repo ==="
microk8s helm3 repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller 2>/dev/null || true
# Use OCI chart from GHCR (official)
# No repo add needed for OCI charts

echo "=== Creating namespaces ==="
microk8s kubectl create namespace $CONTROLLER_NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -
microk8s kubectl create namespace $RUNNER_NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Installing ARC Controller ==="
microk8s helm3 install arc \
  --namespace $CONTROLLER_NAMESPACE \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

echo "=== Waiting for ARC Controller ==="
microk8s kubectl rollout status deployment/arc-gha-rs-controller -n $CONTROLLER_NAMESPACE --timeout=120s

echo "=== Installing Runner Scale Set ==="
microk8s helm3 install $RUNNER_SCALE_SET_NAME \
  --namespace $RUNNER_NAMESPACE \
  --set githubConfigUrl="https://github.com/${GITHUB_REPO}" \
  --set githubConfigSecret.github_token="$GITHUB_PAT" \
  --set minRunners=0 \
  --set maxRunners=3 \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

echo "=== ARC installed ==="
echo "Runner scale set registered as: $RUNNER_SCALE_SET_NAME"
echo "Use 'runs-on: $RUNNER_SCALE_SET_NAME' in your GitHub Actions workflows"
