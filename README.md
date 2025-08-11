# Azure Storage Static Website with Front Door

This repository contains a minimal static website and helper script to deploy it to an Azure Storage account and accelerate it through Azure Front Door.

## Project Structure

```
site/
  index.html
  404.html
  styles.css
  images/
    red-square.svg
    blue-square.svg
deploy.sh
README.md
```

## Running Locally

Serve the site locally to verify the content before deploying:

```bash
python -m http.server --directory site 8000
```

Visit <http://localhost:8000> in your browser.

## Deploy using Azure Portal

1. **Create a Storage Account**
   - Sign in to the [Azure portal](https://portal.azure.com/).
   - Create a new Storage Account (kind: StorageV2) in your resource group and region of choice.
2. **Enable Static Website Hosting**
   - In the storage account, open **Static website** under **Data management**.
   - Enable the feature and set:
     - *Index document*: `index.html`
     - *Error document*: `404.html`
   - Note the **Primary endpoint** URL; this serves your site.
3. **Upload Site Files**
   - Navigate to the `$web` container created by enabling the static website.
   - Upload the contents of the `site/` directory (keeping the folder structure).
4. **Verify the Site**
   - Browse to the primary endpoint URL to confirm the site works.
5. **Create an Azure Front Door**
   - In the portal, create a **Front Door and CDN profile** (Standard/Premium) in the same subscription.
   - Inside the profile, create an **Origin group** and add an **Origin** pointing to your storage account's static website endpoint (host name without `https://`).
   - Create an **Endpoint** and add a **Route** that maps the endpoint to the origin group.
   - Once deployment completes, use the Front Door endpoint hostname to access your site via the CDN.

## Optional: Deploy with Azure CLI

The `deploy.sh` script automates the steps above. You need the Azure CLI logged in (`az login`). Execute:

```bash
./deploy.sh
```

The script creates a resource group, storage account, enables the static website, uploads the `site/` contents, and configures an Azure Front Door profile with a default route.

