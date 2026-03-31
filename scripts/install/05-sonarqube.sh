#!/bin/bash
# 05-sonarqube.sh
# Install SonarQube Community Edition via Helm
# Docs: https://docs.sonarsource.com/sonarqube-community-build/setup-and-upgrade/deploy-on-kubernetes/
#
# Prerequisites:
#   - Set CLUSTER_IP to your node's IP (used for nip.io ingress hostname)
#
# Usage:
#   CLUSTER_IP=192.168.10.4 bash 05-sonarqube.sh

set -e

: "${CLUSTER_IP:?CLUSTER_IP environment variable is required (e.g. 192.168.10.4)}"

NAMESPACE="sonarqube"
HOSTNAME="sonarqube.${CLUSTER_IP}.nip.io"
MONITORING_PASSCODE="sonarmon"  # Change this

echo "=== Adding Helm repo ==="
microk8s helm3 repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
microk8s helm3 repo update

echo "=== Creating namespace ==="
microk8s kubectl create namespace $NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Installing SonarQube CE ==="
microk8s helm3 install sonarqube sonarqube/sonarqube \
  --namespace $NAMESPACE \
  --set community.enabled=true \
  --set monitoringPasscode=$MONITORING_PASSCODE \
  --set ingress.enabled=true \
  --set "ingress.hosts[0].name=$HOSTNAME" \
  --set "ingress.hosts[0].path=/" \
  --set ingress.ingressClassName=public \
  --set resources.requests.memory=1Gi \
  --set resources.limits.memory=2Gi

echo "=== Waiting for SonarQube to be ready ==="
microk8s kubectl rollout status statefulset/sonarqube-sonarqube -n $NAMESPACE --timeout=300s

echo "=== SonarQube installed ==="
echo "Access at: http://$HOSTNAME"
echo "Default credentials: admin / admin (change on first login)"
echo ""
echo "Next steps:"
echo "  1. Log in and create a project"
echo "  2. Generate a project analysis token"
echo "  3. Save the token as SONAR_TOKEN in GitHub secrets"
