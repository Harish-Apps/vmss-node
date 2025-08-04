# VMSS Node.js Example

This project provisions an Azure Virtual Machine Scale Set (VMSS) and deploys a simple Node.js web application. The application serves static HTML/CSS/JS from the root path.

## Prerequisites
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally
- An Azure service principal with **Client ID**, **Client Secret**, **Tenant ID**, and **Subscription ID**
- GitHub repository secrets configured for deployment (see below)

## 1. Provision infrastructure
Update the placeholders in `agent.cli` with your Azure credentials and desired resource names, then run the script locally:

```bash
chmod +x agent.cli
./agent.cli
```

The script will:
1. Authenticate to Azure using the service principal
2. Create a resource group and a two-instance VM Scale Set
3. Run `setup_node.sh` on each VM to install Node.js and register a systemd service

## 2. Configure GitHub Actions
Add the following secrets to your repository so the pipeline can deploy:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_RESOURCE_GROUP` (matches the `RG` in `agent.cli`)
- `VMSS_NAME` (matches the `VMSS` in `agent.cli`)

## 3. Deploy application
Push or merge changes to the `main` branch. The workflow defined in `.github/workflows/deploy.yml` runs tests and then deploys the latest code to every VM in the scale set.

Once the workflow completes, visit the public IP of any instance to see the app.

## Testing locally
```bash
npm test
```

The test starts the server on port 3000 and ensures it responds successfully.
