#!/usr/bin/env bash

# Script to provision an AKS cluster with Azure Monitor, Managed Prometheus and Managed Grafana.
# It creates the required resources and deploys a sample application and alerting rules.
# Prerequisites: Azure CLI with the 'aks-preview' and 'amg' extensions, logged in with sufficient permissions.

set -euo pipefail

# ---------- Configuration ----------
RESOURCE_GROUP="aks-observability-rg"
LOCATION="eastus"
AKS_NAME="aks-observability"
LOG_ANALYTICS_WS="aks-la"
GRAFANA_NAME="aks-grafana"

# ---------- Resource group ----------
echo "Creating resource group $RESOURCE_GROUP in $LOCATION"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# ---------- Log Analytics ----------
echo "Creating Log Analytics workspace"
az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$LOG_ANALYTICS_WS"

WORKSPACE_ID=$(az monitor log-analytics workspace show -g "$RESOURCE_GROUP" -n "$LOG_ANALYTICS_WS" --query id -o tsv)

# ---------- AKS cluster ----------
echo "Creating AKS cluster with Container Insights and Azure Monitor managed Prometheus"
az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_NAME" \
  --location "$LOCATION" \
  --enable-addons monitoring \
  --enable-azure-monitor-metrics \
  --workspace-resource-id "$WORKSPACE_ID" \
  --node-count 2 \
  --generate-ssh-keys

# Get cluster credentials for kubectl
az aks get-credentials -g "$RESOURCE_GROUP" -n "$AKS_NAME"

# ---------- Sample workload ----------
echo "Deploying sample application with Prometheus metrics"
kubectl apply -f k8s/sample-app.yaml

# ---------- Alert rules ----------
echo "Applying Prometheus alerting rules"
kubectl apply -f alerts/pod-availability-rule.yaml

# ---------- Managed Grafana ----------
echo "Creating Managed Grafana instance"
az grafana create \
  --name "$GRAFANA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard

# Assign current user access to Grafana instance
USER_ID=$(az ad signed-in-user show --query objectId -o tsv)
az role assignment create --assignee "$USER_ID" --role "Grafana Admin" --scope $(az grafana show -g "$RESOURCE_GROUP" -n "$GRAFANA_NAME" --query id -o tsv)

echo "Grafana instance created. Import grafana/slo-dashboard.json to visualize SLOs."

echo "Deployment complete."
