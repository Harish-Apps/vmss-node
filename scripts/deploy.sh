#!/usr/bin/env bash
set -euo pipefail

# Login (use your existing SP 'azurespnew' if you prefer)
# az login --service-principal -u APP_ID -p PASSWORD --tenant TENANT_ID

pushd terraform
terraform init
terraform apply -auto-approve
# capture outputs for later
RG=$(terraform output -raw resource_group)
WS=$(terraform output -raw workspace_name)
LOC=$(terraform output -raw location)
CC=$(terraform output -raw compute_cluster)
popd

# Configure AML CLI defaults
az extension add -n ml -y
az configure --defaults group="$RG" workspace="$WS" location="$LOC"

echo "Workspace: $WS"
echo "Compute:   $CC"
