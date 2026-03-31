# cluster-status.ps1
# Runs cluster diagnostics using local kubectl
# Requires: kubectl configured for the MicroK8s cluster
# Usage: .\cluster-status.ps1

function Section($title) {
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
}

Section "NODES"
kubectl get nodes -o wide

Section "NAMESPACES"
kubectl get namespaces

Section "ALL PODS"
kubectl get pods --all-namespaces -o wide

Section "SERVICES"
kubectl get svc --all-namespaces

Section "INGRESSES"
kubectl get ingress --all-namespaces

Section "DEPLOYMENTS"
kubectl get deployments --all-namespaces

Section "STORAGE"
kubectl get pvc --all-namespaces

Section "SECRETS (names only)"
kubectl get secrets --all-namespaces --no-headers | ForEach-Object { ($_ -split '\s+')[0..2] -join ' ' }

Section "CONFIGMAPS"
kubectl get configmaps --all-namespaces --no-headers | ForEach-Object { ($_ -split '\s+')[0..1] -join ' ' }

Section "RESOURCE USAGE"
kubectl top nodes 2>$null
kubectl top pods --all-namespaces 2>$null
