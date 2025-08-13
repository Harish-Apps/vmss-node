#!/usr/bin/env bash
set -euo pipefail

# If you changed names, override compute here
# yq can be used to set dynamically; for simplicity we rely on defaults
az ml job create --file aml/job.yml

# Tail logs
JOB_ID=$(az ml job list --query "[0].name" -o tsv)
echo "Streaming logs for $JOB_ID..."
az ml job stream -n "$JOB_ID"
