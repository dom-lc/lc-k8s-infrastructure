#!/bin/bash

# List of cluster names to delete
# Refer to init.sh for the list of cluster names that have been created
# You can also check the existing clusters with: kind get clusters
CLUSTERS=("surveillance-green")

# Loop through each and delete
for CLUSTER in "${CLUSTERS[@]}"; do
  echo "Deleting cluster: $CLUSTER"
  kind delete cluster --name "$CLUSTER"
done