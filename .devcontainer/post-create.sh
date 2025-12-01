#!/usr/bin/env bash
set -e

# Herramientas básicas
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg lsb-release make git

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -LSs https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# kind
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64"
chmod +x kind
sudo mv kind /usr/local/bin/kind

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Devcontainer listo. Ahora puedes ejecutar: make kind-up"
