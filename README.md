# K8S Infra

Repository that mocks the lc-k8s-apps-infrastucture. </br></br>
*Note that this repository will be used to demonstrate concepts and does not follow the best security practices.*

## Infra Workflow

This directory contains scripts to setup your clusters and bootstrap them. It also permits deletion. Run these scripts as root user.

* init.sh: Installs kind and sets up our kind single node clusters.
* bootstrap.sh: Adds required Helm repositories and installs Vault & Argo-Cd via Helm to our clusters.
* destroy.sh: Destorys all our kind clusters

A variable has been preset in each script to for the clusters, for now just one cluster is getting setup:

```
CLUSTERS=("surveillance-green")
```

To add cluster add a space between the values. (ag. CLUSTERS=("surveillance-green", "green-prod")). </br>
If you modify this value, ensure it is reflected in all of your scripts. (init.sh, bootstrap.sh, destroy.sh). 
</br></br>

For the ```bootstrap.sh``` do not forget to set your github PAT before running the script.

```
GITHUB_PAT="" # Put your GitHub PAT here
```

To validate your secret has been added to your vault, run:

```
kubectl exec -n vault vault-0 -- \
  vault kv get secret/github_pat
```

## Real World Use

As the original repository does, I see this repo as the one with the Terraform configuration files and GitHub action worflows to create aks clusters, nodepools and resources. 