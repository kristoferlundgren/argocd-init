#!/bin/sh -x

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm search repo argo/argo-cd --versions | head -6

# Install ArgoCD:
ARGOCD_VERSION=$(grep "targetRevision:" templates/application.yaml | tr -cd "[:digit:].")
helm upgrade --install argocd --create-namespace -n argocd argo/argo-cd --version ${ARGOCD_VERSION}
kubectl apply -k templates

# Connect to and show status:
kubens argocd
argocd login --core
argocd app list
# Due to this ArgoCD issue, apps in other namespaces do no show when using login --core.
#   https://github.com/argoproj/argo-cd/issues/16426
# Pending PR:
#   https://github.com/argoproj/argo-cd/pull/23115
