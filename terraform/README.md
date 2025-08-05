# Azure Hub-and-Spoke Network Terraform

This directory contains a modular Terraform configuration that provisions a multi-region, hub-and-spoke virtual network topology in Azure. It includes:

* Hub VNets with gateway, firewall and internal load balancer
* Spoke VNets for `dev`, `test` and `prod` environments
* Subnet-level NSGs with default deny rules
* User Defined Routes forcing traffic through Azure Firewall
* VNet peering between spokes and their regional hub
* Multi-region support for **East US** and **West Europe**

## Structure

```
terraform/
├── main.tf              # Root module orchestrating hubs and spokes
├── variables.tf         # Region and environment configuration
├── outputs.tf
├── provider.tf          # Provider and remote backend definition
├── terraform.tfvars.example
└── modules/
    ├── hub/             # Hub VNet, Azure Firewall and internal ALB
    └── spoke/           # Spoke VNets, NSGs, UDRs and peering
```

## Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.0+
* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
* An Azure subscription with permission to create networking resources

Authenticate with Azure before running Terraform:

```bash
az login
```

## Remote State Backend

State is stored remotely in Azure Storage to enable collaboration and locking. Create a storage account and container:

```bash
az group create --name rg-tfstate --location eastus
az storage account create --name <storage_account> --resource-group rg-tfstate --location eastus --sku Standard_LRS
az storage container create --name tfstate --account-name <storage_account>
```

Create a `backend.tfvars` file (not committed to source control):

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "<storage_account>"
container_name       = "tfstate"
key                  = "network.tfstate"
```

## Usage

Run Terraform from this directory or from [Azure Cloud Shell](https://shell.azure.com/):

```bash
cd terraform
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

To customise regions or address spaces, copy `terraform.tfvars.example` to `terraform.tfvars` and adjust values. Separate state files per environment or region can be maintained by changing the `key` in `backend.tfvars`.

## Best Practices

* **Remote state**: Never commit `terraform.tfstate` files to Git. Use an Azure Storage backend with state locking.
* **Separate state per environment**: Use different state keys or storage containers for dev/test/prod.
* **Modular design**: Modules in `modules/` can be reused for new regions or environments by updating `variables.tf` or providing your own `terraform.tfvars`.
* **Formatting and validation**: Run `terraform fmt` and `terraform validate` before committing changes.
* **Access control**: Apply Azure RBAC and firewall rules to protect the state storage account.

## Clean-up

To remove all provisioned resources:

```bash
terraform destroy
```

Ensure remote state files are deleted from the storage account when no longer required.
