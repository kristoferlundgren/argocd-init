#!/bin/sh -x

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm search repo argo/argo-cd --versions | head -6

# Install ArgoCD:
kubectl create namespace argocd
ARGOCD_VERSION=$(grep "targetRevision:" templates/Application.yaml | tr -cd "[:digit:].")
helm template argocd --create-namespace -n argocd argo/argo-cd --version ${ARGOCD_VERSION} \
  --set dex.containerSecurityContext.runAsUser=null \
  --set redis.securityContext.runAsUser=null \
  | kubectl apply --server-side --force-conflicts -f -
kubectl wait --for=condition=Established --timeout=60s crd/appprojects.argoproj.io
kubectl apply --force -k templates

# Connect to and show status:
kubens argocd
kubectl -n argocd wait --for=condition=Available --timeout=60s deployment/argocd-server
argocd login --core
argocd app list
# Due to this ArgoCD issue, apps in other namespaces do no show when using login --core.
#   https://github.com/argoproj/argo-cd/issues/16426
# Pending PR:
#   https://github.com/argoproj/argo-cd/pull/23115
set +x
echo ArgoCD sevice URL:
echo "  https://argocd-server.argocd.svc.cluster.local/"
echo ArgoCD "admin" password:
printf '  '; kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; printf '\n'
echo
