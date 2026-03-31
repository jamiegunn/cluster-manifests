#!/bin/bash
echo "=== NODES ==" && microk8s kubectl get nodes -o wide
echo -e "\n=== NAMESPACES ===" && microk8s kubectl get namespaces
echo -e "\n=== ALL PODS ===" && microk8s kubectl get pods --all-namespaces -o wide
echo -e "\n=== SERVICES ===" && microk8s kubectl get svc --all-namespaces
echo -e "\n=== INGRESSES ===" && microk8s kubectl get ingress --all-namespaces
echo -e "\n=== DEPLOYMENTS ===" && microk8s kubectl get deployments --all-namespaces
echo -e "\n=== HELM RELEASES ===" && microk8s helm3 list --all-namespaces
echo -e "\n=== MICROK8S ADDONS ===" && microk8s status --format short
echo -e "\n=== STORAGE ===" && microk8s kubectl get pvc --all-namespaces
echo -e "\n=== SECRETS (names only) ===" && microk8s kubectl get secrets --all-namespaces --no-headers | awk '{print $1, $2, $3}'
echo -e "\n=== CONFIGMAPS ===" && microk8s kubectl get configmaps --all-namespaces --no-headers | awk '{print $1, $2}'
echo -e "\n=== RESOURCE USAGE ===" && microk8s kubectl top nodes 2>/dev/null; microk8s kubectl top pods --all-namespaces 2>/dev/null
