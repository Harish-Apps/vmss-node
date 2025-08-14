# AKS Observability Stack

This project deploys an **Azure Kubernetes Service (AKS)** cluster with:

- **Container Insights** for basic metrics and logs.
- **Azure Monitor managed service for Prometheus** for scrape-based metrics and alerting.
- **Azure Managed Grafana** for dashboards.
- A sample application exposing Prometheus metrics, SLO dashboard, and alert rules.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with the `aks-preview` and `amg` extensions.
- Logged in to Azure: `az login`
- A subscription where you have permission to create resources.

## Deployment

```bash
# Make script executable
chmod +x infra/deploy-aks-monitoring.sh

# Run the deployment script
./infra/deploy-aks-monitoring.sh
```

The script performs the following steps:

1. Creates a resource group and Log Analytics workspace.
2. Provisions an AKS cluster with Container Insights and managed Prometheus enabled.
3. Deploys a sample application that exposes Prometheus metrics.
4. Applies a Prometheus `PrometheusRule` for a simple SLO alert (error rate > 1%).
5. Creates a Managed Grafana instance and grants the current user admin access.

## SLO Dashboard

Import `grafana/slo-dashboard.json` into the Managed Grafana instance to visualize the request success rate for the sample application.

## Alerting

The `alerts/pod-availability-rule.yaml` file defines a basic alerting rule that triggers when more than 1% of requests fail for 5 minutes. In a real environment you can configure alert routing to email, Teams, etc., using Azure Monitor alerting.

## Cleanup

Remove all deployed resources when you are done:

```bash
az group delete --name aks-observability-rg --yes --no-wait
```

## Notes

This repository provides reference scripts and manifests. Review and adjust variables in `infra/deploy-aks-monitoring.sh` to fit your environment.
