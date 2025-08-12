# DevOps Cloud Engineer Blog on Azure Functions

This repository contains a personal blog for a DevOps/cloud engineer. The site is a single `index.html` page served through an Azure Function and shows the current time and the latest public GitHub repositories.

## Infrastructure Setup

Provision the required Azure resources using the provided script:

```bash
./azure-setup.sh
```

The script creates a resource group, storage account and a Python Azure Function App in *Central India*.

## Local Development

1. Install [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local).
2. Start the function:

```bash
func start
```


## CI/CD

Whenever code is pushed to the `main` branch, GitHub Actions automatically deploys the latest version to the Azure Function. The workflow uses a service principal stored in the repository secret `AZURE_CREDENTIALS`.

## Access

After a successful deployment the blog is available at:

```
https://dhaappsaznewf.azurewebsites.net
```

Replace the function app name in the URL if you created a different one.
