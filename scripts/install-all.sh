#!/bin/bash
# install-all.sh
# Master script — runs all install scripts in order
# Run from the VM after MicroK8s is installed
#
# Prerequisites (set as environment variables before running):
#   GITHUB_PAT     — classic PAT with 'repo' scope (for ARC)
#   GITHUB_REPO    — e.g. jamiegunn/hello-world-dotnet (for ARC runner registration)
#   GITHUB_USER    — your GitHub username
#   GHCR_PAT       — PAT with read:packages scope (for image pull secret)
#   CLUSTER_IP     — VM IP address, e.g. 192.168.10.4
#
# Usage:
#   GITHUB_PAT=xxx GITHUB_REPO=jamiegunn/hello-world-dotnet \
#   GITHUB_USER=jamiegunn GHCR_PAT=xxx CLUSTER_IP=192.168.10.4 \
#   bash install-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install"

: "${GITHUB_PAT:?}"
: "${GITHUB_REPO:?}"
: "${GITHUB_USER:?}"
: "${GHCR_PAT:?}"
: "${CLUSTER_IP:?}"

echo "======================================"
echo "  GitOps Platform — Full Install"
echo "======================================"

run_step() {
  local script="$1"
  echo ""
  echo "--- Running: $script ---"
  bash "$SCRIPT_DIR/$script"
}

run_step 01-microk8s-addons.sh
run_step 02-argocd.sh
run_step 03-rancher.sh
run_step 04-arc.sh
run_step 05-sonarqube.sh
run_step 06-helloworld-app.sh

echo ""
echo "======================================"
echo "  Install complete"
echo "======================================"
echo ""
echo "Services:"
echo "  HelloWorld   http://helloworld.${CLUSTER_IP}.nip.io"
echo "  SonarQube    http://sonarqube.${CLUSTER_IP}.nip.io"
echo "  Rancher      https://rancher.local"
echo "  Argo CD      kubectl port-forward svc/argocd-server -n argocd 8080:443"
