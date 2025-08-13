# Azure LLM Training Platform

This repository provides a minimal end-to-end setup for fine-tuning a small language model on Azure using Terraform and Azure Machine Learning (v2). It provisions all required Azure resources, deploys a CPU-based compute cluster that scales to zero when idle, and includes a sample job that fine-tunes DistilGPT‑2 on a tiny dataset.

## Repository structure

```
terraform/               # Infrastructure as Code
  providers.tf
  variables.tf
  main.tf
  outputs.tf
  terraform.tfvars.example
aml/                     # Azure ML job definition
  job.yml
src/
  train.py               # Hugging Face training script
scripts/                 # Helper shell scripts
  deploy.sh              # Deploy infra and configure defaults
  submit_job.sh          # Submit example training job
  cleanup.sh             # Destroy resources
README.md
```

## Prerequisites

* Azure subscription with rights to create resources
* [Azure CLI](https://learn.microsoft.com/cli/azure/) logged in (`az login`)
* Azure ML CLI extension: `az extension add -n ml -y`
* Terraform ≥ 1.5 with AzureRM provider v3.x
* Optional: Python 3.10+ if running `src/train.py` locally

## Deployment

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and adjust values if needed.
2. Deploy the infrastructure:

```bash
bash scripts/deploy.sh
```

This creates a resource group, storage account, key vault, application insights, container registry, Azure ML workspace and a CPU compute cluster.

## Submit the sample job

Run:

```bash
bash scripts/submit_job.sh
```

The command submits the training job defined in `aml/job.yml`, streams logs to your terminal, and trains DistilGPT‑2 for one epoch on a subset of the Wikitext‑2 dataset.

## Download artifacts

After the job completes, download the trained model:

```bash
JOB=<job-name-from-logs>
az ml job download -n "$JOB" --download-path ./artifacts
```

Model files are stored under `artifacts/outputs/`.

## Cleanup

Destroy all Azure resources to avoid charges:

```bash
bash scripts/cleanup.sh
```

## Notes

* The compute cluster scales down to zero when idle to minimize cost.
* To train on GPU hardware, update `vm_size` in `terraform/terraform.tfvars` to a GPU SKU and change the job environment to a CUDA-enabled image such as `azureml:AzureML-acpt-pytorch-2.2-cuda12.1@latest`.
* For multi-node distributed training, increase `max_nodes` in `terraform/terraform.tfvars` and adjust `aml/job.yml` accordingly.
