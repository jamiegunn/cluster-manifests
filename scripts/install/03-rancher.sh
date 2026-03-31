#!/bin/bash
# 03-rancher.sh
# Install Rancher via Helm
# Docs: https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster

set -e

NAMESPACE="cattle-system"
RANCHER_HOSTNAME="rancher.local"  # Change to your desired hostname

echo "=== Adding Helm repos ==="
microk8s helm3 repo add rancher-stable https://releases.rancher.com/server-charts/stable
microk8s helm3 repo update

echo "=== Creating namespace ==="
microk8s kubectl create namespace $NAMESPACE --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "=== Installing Rancher ==="
microk8s helm3 install rancher rancher-stable/rancher \
  --namespace $NAMESPACE \
  --set hostname=$RANCHER_HOSTNAME \
  --set bootstrapPassword=admin \
  --set ingress.ingressClassName=public \
  --set replicas=1

echo "=== Waiting for Rancher to be ready ==="
microk8s kubectl rollout status deployment/rancher -n $NAMESPACE --timeout=300s

echo "=== Rancher installed ==="
echo "Access at: https://$RANCHER_HOSTNAME"
echo "Bootstrap password: admin (you will be prompted to change it on first login)"
