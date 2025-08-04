#!/usr/bin/env bash
set -euo pipefail

#──────────────────────────────── User-configurable -───────────────────────────
RESOURCE_GROUP="myvmmsrgg"
LOCATION="eastus"
VMSS_NAME="myVmsss"
INSTANCE_COUNT=2
ADMIN_USERNAME="azureuser"
CUSTOM_SCRIPT_URL="https://raw.githubusercontent.com/Harish-Apps/vmss-node/main/install_node_app.sh"

MIN_CAPACITY=2
MAX_CAPACITY=5
DEFAULT_CAPACITY=2
SCALE_OUT_THRESHOLD=70  SCALE_OUT_CHANGE=1
SCALE_IN_THRESHOLD=30   SCALE_IN_CHANGE=1
#──────────────────────────────── Script starts -───────────────────────────────
echo "[create_vmss.sh] Creating resource group…"
az group create -n "$RESOURCE_GROUP" -l "$LOCATION"

echo "[create_vmss.sh] Creating VM scale set…"
az vmss create -g "$RESOURCE_GROUP" -n "$VMSS_NAME" \
  --image Ubuntu2204 --orchestration-mode Flexible \
  --instance-count "$INSTANCE_COUNT" \
  --admin-username "$ADMIN_USERNAME" --generate-ssh-keys \
  --upgrade-policy-mode automatic

echo "[create_vmss.sh] Installing custom-script extension…"
az vmss extension set \
  --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.1 \
  -g "$RESOURCE_GROUP" --vmss-name "$VMSS_NAME" \
  --settings "{\"fileUris\":[\"$CUSTOM_SCRIPT_URL\"],\"commandToExecute\":\"bash install_node_app.sh\"}" \
  --force-update

# ── Autoscale profile & rules ────────────────────────────────────────────────
AUTOSCALE_NAME="autoscale"
echo "[create_vmss.sh] Configuring autoscale profile…"
az monitor autoscale create \
  -g "$RESOURCE_GROUP" --resource "$VMSS_NAME" \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  -n "$AUTOSCALE_NAME" --min-count $MIN_CAPACITY \
  --max-count $MAX_CAPACITY --count $DEFAULT_CAPACITY

echo "[create_vmss.sh] Creating scale-out rule…"
az monitor autoscale rule create -g "$RESOURCE_GROUP" --autoscale-name "$AUTOSCALE_NAME" \
  --condition "Percentage CPU > ${SCALE_OUT_THRESHOLD} avg 5m" --scale out $SCALE_OUT_CHANGE

echo "[create_vmss.sh] Creating scale-in rule…"
az monitor autoscale rule create -g "$RESOURCE_GROUP" --autoscale-name "$AUTOSCALE_NAME" \
  --condition "Percentage CPU < ${SCALE_IN_THRESHOLD} avg 5m" --scale in $SCALE_IN_CHANGE

# ── NOTE: no additional lb rule needed (LBRule already handles port 80) ──────
PUBLIC_IP_NAME="${VMSS_NAME}LBPublicIP"
echo "[create_vmss.sh] Getting public IP…"
PUBLIC_IP=$(az network public-ip show -g "$RESOURCE_GROUP" -n "$PUBLIC_IP_NAME" \
            --query ipAddress -o tsv)

echo "✔ Deployment complete – open:  http://$PUBLIC_IP"
  