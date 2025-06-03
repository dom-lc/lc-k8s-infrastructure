#################################################################
### Functions
#################################################################

# Add required Helm repositories
add_helm_repos() {
  echo "Adding Helm repositories..."
  # Argo-CD Helm Repo
  helm repo add argo https://argoproj.github.io/argo-helm
  # Step 2: Add HashiCorp Helm repo 
  helm repo add hashicorp https://helm.releases.hashicorp.com
  # Update the Helm repositories
  # This command will fetch the latest charts from all the added repositories
  helm repo update
}

# Install Vault and Argo-CD on cluster
install_tools() {
  local cluster=$1
  kubectl config use-context "kind-$cluster"

  echo "*********************************************************"
  echo "** Installing Vault on cluster: $cluster ..."
  echo "*********************************************************"
  
  # Install Vault in dev mode
  helm upgrade --install vault hashicorp/vault \
    --namespace vault \
    --create-namespace \
    --set "server.dev.enabled=true" \
    --set "injector.enabled=false"
  
  # Wait for the Vault pod to be ready
  echo "***************************************"
  echo "⏳ Waiting for Vault pod to be ready..."
  kubectl wait --namespace vault \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=vault \
    --timeout=120s

  # Set Vault environment variables
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN="root"  # default in dev mode

  # Add a the github pat to the vault
  kubectl exec -n vault vault-0 -- \
    vault kv put secret/github_pat github_pat=$GITHUB_PAT

  echo ""
  echo ""

  echo "*********************************************************"
  echo "** Installing Argo-CD on cluster: $cluster ..." 
  echo "*********************************************************"
  # Install Argo-CD
  helm install argocd argo/argo-cd \
    --version "$ARGO_VERSION" \
    --namespace "argocd" \
    --create-namespace \
    --set server.service.type=NodePort
}

# Get Argo-Cd initial admin credentials from the clusters
fetch_argo_credentials() {
  local cluster=$1
  kubectl config use-context "kind-$cluster"
  # Check if the secret exists
  # If it does exist, print the credentials and break the loop
  # If it does not exist, wait for 5 seconds and check again
  echo ""
  echo ""
  echo "⏳ Waiting for ArgoCD secret..."
  for i in {1..60}; do
  SECRET=$(kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" -o jsonpath='{.data.password}' 2>/dev/null)
  if [[ -n "$SECRET" ]]; then
        echo "************************************"
        echo "** Cluster $cluster **"
        echo "************************************"
        echo ""
        echo "Username: admin"
        echo "Password: $(kubectl get secret argocd-initial-admin-secret -n argocd \
          -o jsonpath='{.data.password}' | base64 --decode)" && echo
        echo "************************************"
        echo ""
    break
  fi
  sleep 5
done
}

#################################################################
### Core
#################################################################

# Variables
# Please refer to the init.sh script for the list of cluster names
# or use: kind get clusters
# "surveillance-green" 
CLUSTERS=("surveillance-green")
ARGO_VERSION="6.10.2" # same version as livraison-continue
GITHUB_PAT="" # Put your GitHub PAT here

# Add all required Helm repositories
add_helm_repos

# Install ArgoCD on each cluster
for CLUSTER in "${CLUSTERS[@]}"; do
  install_tools "$CLUSTER"
done

# Get the ArgoCD admin password
echo "Fetching initial ArgoCD server credentials..."
for CLUSTER in "${CLUSTERS[@]}"; do
  fetch_argo_credentials "$CLUSTER"
done

# Set the ArgoCD server URL to be served on localhost
echo "ArgoCD installation and credential retrieval complete."
echo "You can access ArgoCD by forwarding you port."
echo "First select the cluster you want to access with: kubectl config use-context kind-<cluster_name>"
echo "Then run the following command to forward the port:"
echo "kubectl port-forward svc/argocd-server -n argocd <desired-port>:80"