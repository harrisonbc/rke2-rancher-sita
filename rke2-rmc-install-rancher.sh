#!/usr/bin/env bash

# Set Up variables
set -a
source variables.env
set +a

# We now install Cert Manager if using rancher-signed certificates

# echo 
# echo "Install Cert-Manager onto Cluster."
# echo "=================================="
# echo
# helm repo add jetstack https://charts.jetstack.io
# helm repo update
# kubectl create namespace cert-manager
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml

# helm upgrade --install cert-manager jetstack/cert-manager \
#   --namespace cert-manager --version $CERT_MANAGER_VERSION

# kubectl rollout status deployment -n cert-manager cert-manager
# kubectl rollout status deployment -n cert-manager cert-manager-webhook


# helm repo add rancher https://releases.rancher.com/server-charts/latest
helm repo add rancher-prime https://charts.rancher.com/server-charts/prime
helm repo update

kubectl create namespace cattle-system

echo 
echo "Create Certificate Secrets."
echo "==========================="

kubectl -n cattle-system create secret tls tls-rancher-ingress \
 --cert=tls.cer \
 --key=tls.key

kubectl -n cattle-system create secret generic tls-ca \
 --from-file=cacerts.pem

# Finally we can install Rancher
echo 
echo "Install Rancher onto Cluster."
echo "============================="
echo

helm upgrade --install rancher rancher-prime/rancher \
   --namespace cattle-system \
   --version=$RANCHER_VERSION \
   --set bootstrapPassword="$RANCHER_BOOTSTRAP_PASSWORD" \
   --set hostname=$CLUSTERNAME \
   --set proxy=http://${RANCHER_PROXY} \
   --set noProxy=${RANCHER_NO_PROXY} \
   --set ingress.tls.source=secret \
   --set privateCA=true \
   --set agentTLSMode="system-store"

kubectl rollout status deployment/rancher -n cattle-system

echo "RKE2 & Rancher Installed."
echo "========================="
echo
