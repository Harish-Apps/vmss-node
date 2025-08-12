# Personal Blog on Azure Functions

This project hosts a simple personal blog written in HTML and CSS and served through an Azure Function. Deployment is automated via GitHub Actions using the Azure Functions Core Tools.

## Infrastructure Setup

Use the provided script to create the required Azure resources:

```bash
./azure-setup.sh
```

This script runs:

```bash
az group create --name functionRG --location centralindia
az storage account create --name dhaappsaznefunc --location centralindia --resource-group functionRG --sku Standard_LRS
az functionapp create --resource-group functionRG --consumption-plan-location centralindia --runtime python --runtime-version 3.10 --functions-version 4 --name dhaappsaznewf --os-type linux --storage-account dhaappsaznefunc
```

## Local Development

1. Install [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local).
2. Run the function locally:

```bash
func start
```

Visit `http://localhost:7071` to view the blog.

## CI/CD

A GitHub Actions workflow (`.github/workflows/deploy.yml`) publishes the function app whenever changes are pushed to the `main` branch. The workflow requires a service principal stored in the repository secret `AZURE_CREDENTIALS`.

## Access

After a successful deployment, the blog is available at:

```
https://dhaappsaznewf.azurewebsites.net
```

Replace the function app name in the URL if you create a different one.
