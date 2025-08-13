# Azure LLM Training Platform (CPU)

This project provisions an Azure Machine Learning (AML) workspace and a CPU compute cluster, then runs a sample job that fine‑tunes [DistilGPT‑2](https://huggingface.co/distilgpt2) on the tiny Wikitext‑2 dataset. Infrastructure is managed with Terraform and jobs are submitted with the Azure ML CLI (v2).

## Repository Layout
```
terraform/               # Terraform IaC for AML workspace & compute
aml/job.yml              # Sample AML command job definition
src/train.py             # Hugging Face training script
scripts/deploy.sh        # Provision infra and configure CLI defaults
scripts/submit_job.sh    # Submit the example training job
scripts/cleanup.sh       # Destroy all provisioned resources
```

## Prerequisites
* Azure subscription with permissions to create resources
* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`) and logged in
* ML extension: `az extension add -n ml -y`
* [Terraform](https://www.terraform.io/downloads.html) ≥ 1.5
* Optional: Python 3.10+ if you want to run `src/train.py` locally for testing

## Deploy Infrastructure
```
bash scripts/deploy.sh
```
This initializes Terraform and creates the resource group, supporting services (Storage, Key Vault, App Insights, ACR), AML workspace and a **CPU** compute cluster (`Standard_D2_v2`) that scales to zero when idle. The script configures the Azure ML CLI defaults using the created workspace.

## Run the Sample Training Job
```
bash scripts/submit_job.sh
```
The job uses the curated environment `AzureML-pytorch-2.2-ubuntu20.04-py310-cpu@latest` and runs the training script on the CPU cluster. Logs are streamed automatically. After the job completes, the model artifacts can be downloaded with:
```
JOB=<job-name-from-logs>
az ml job download -n "$JOB" --download-path ./artifacts
```

## Cleanup
Destroy all deployed resources when done:
```
bash scripts/cleanup.sh
```

## Notes
* Change values in `terraform/terraform.tfvars` (copy from the `.example` file) to customize naming or region.
* To experiment with multiple nodes, increase `max_nodes` in the tfvars file and set `instance_count` and `distribution` in `aml/job.yml` accordingly.
* For production scenarios, consider using private networking and managed identities.
