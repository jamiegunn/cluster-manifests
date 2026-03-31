#!/bin/bash
# 01-microk8s-addons.sh
# Enable required MicroK8s add-ons
# Run on the VM after MicroK8s is installed: sudo snap install microk8s --classic

set -e

echo "=== Enabling MicroK8s add-ons ==="

microk8s enable dns
microk8s enable storage
microk8s enable hostpath-storage
microk8s enable ingress
microk8s enable helm
microk8s enable helm3
microk8s enable cert-manager
microk8s enable ha-cluster

echo "=== Waiting for add-ons to be ready ==="
microk8s status --wait-ready

echo "=== Add-ons enabled ==="
microk8s status --format short
