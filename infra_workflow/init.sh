#!/bin/bash

### Designed for ubuntu 24.04 WSL2
### This script will install kind and create a single node cluster with the desired configuration for each entry in the CLUSTERS array
### Run as root

# Install Kind
# Uncomment this block if needed for your setup
# # For AMD64 / x86_64
# [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
# Using WSL so not needed
# # For ARM64
# [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64
# chmod +x ./kind
# sudo mv ./kind /usr/local/bin/kin

### Variables ###
# you can add single node clusters as needed by adding to the array
# Note: The cluster name must be unique
# Please do not forget to reflect these values in the bootstrap.sh & destroy.sh scripts
CLUSTERS=("surveillance-green")

# Create the kind Single Node Clusters
for CLUSTER in "${CLUSTERS[@]}"; do
  kind create cluster --name "$CLUSTER" --config ../templates/kind/kind.config.yaml
done

# Open permissions on docker socket
# Bad approach here but didn't want to break my head
sudo chmod 666 /var/run/docker.sock