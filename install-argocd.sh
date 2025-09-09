#!/bin/sh -x

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm search repo argo/argo-cd --versions | head -6

ARGOCD_VERSION=$(grep "targetRevision:" application.yaml | tr -cd "[:digit:].")
helm upgrade --install argocd --create-namespace -n argocd argo/argo-cd --version ${ARGOCD_VERSION}

kubectl apply -k .
kubens argocd
argocd login --core
argocd app list
