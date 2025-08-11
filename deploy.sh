#!/usr/bin/env bash
set -euo pipefail

# Variables - customize these values
RESOURCE_GROUP="my-static-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="mystatic$RANDOM"
FRONT_DOOR_NAME="myFrontDoor$RANDOM"
ENDPOINT_NAME="main-endpoint"

# Create resource group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create storage account
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2

# Enable static website hosting
az storage blob service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --static-website \
  --index-document index.html \
  --404-document 404.html

# Upload site contents
az storage blob upload-batch \
  --account-name "$STORAGE_ACCOUNT" \
  --destination '$web' \
  --source ./site

# Create Azure Front Door profile (Standard)
az afd profile create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FRONT_DOOR_NAME" \
  --sku Standard_AzureFrontDoor

# Create endpoint
az afd endpoint create \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_NAME" \
  --endpoint-name "$ENDPOINT_NAME" \
  --enabled-state Enabled

# Create origin group
az afd origin-group create \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_NAME" \
  --origin-group-name "storage-origin-group"

# Obtain static website hostname
ORIGIN_HOST=$(az storage account show -n "$STORAGE_ACCOUNT" -g "$RESOURCE_GROUP" --query "primaryEndpoints.web" -o tsv | sed -e 's#^https://##' -e 's#/$##')

# Create origin pointing to storage account static website endpoint
az afd origin create \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_NAME" \
  --origin-group-name "storage-origin-group" \
  --origin-name "storage-origin" \
  --host-name "$ORIGIN_HOST" \
  --origin-host-header "$ORIGIN_HOST" \
  --http-port 80 \
  --https-port 443

# Add route from Front Door to the storage origin
az afd route create \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_NAME" \
  --endpoint-name "$ENDPOINT_NAME" \
  --route-name "route-to-storage" \
  --origin-group "storage-origin-group" \
  --supported-protocols Http Https \
  --https-redirect Enabled \
  --link-to-default-domain Enabled

echo "Deployment complete. Use the Azure portal to find the Front Door endpoint URL."
