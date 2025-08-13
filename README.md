# AKS Observability Reference

This project provides an end-to-end observability stack for Azure Kubernetes Service (AKS) using **Managed Prometheus**, **Container Insights** (Azure Monitor Agent + Data Collection Rule), **Log Analytics**, and **Azure Managed Grafana**.

## Architecture

```
+----------------------+         +---------------------------+
| Azure Managed        |<------->| Azure Monitor Workspace   |<- PromQL
| Grafana (Managed MI) |   RBAC  | (Prometheus data store)   |
+----------+-----------+         +------------+--------------+
           ^                                     ^
           |                                     |
           | Azure Auth (Monitoring Data Reader) |
           |                                     | DCE/DCR (MSPROM-*)
           |                                     |
+----------+-------------------+     +-----------+------------------+
| AKS Cluster (Managed ID)    |----->| Managed Prometheus Addon     |
|  - Workloads (/metrics)     |      |  (ama-metrics RS/DS)         |
|  - pod annotations          |      +------------------------------+
|                             |
|  AMA (azuremonitor-containers) -> DCR (MSCI-*) -> Log Analytics   |
+-----------------------------+                                     |
                                                                      v
                                                          Log Analytics (KQL)
```

Enabling Managed Prometheus and Container Insights creates **MSPROM-\*** and **MSCI-\*** Data Collection Rules and installs the required agents.

## Repository Layout

```
/infra   Terraform configuration for core resources (RG, AMW, LAW, AKS, Grafana)
/alerts  Terraform modules for Prometheus rule groups and log alerts
/k8s     Kubernetes manifests for demo apps and custom scrape configs
grafana/dashboards  Example SLO dashboard JSON
```

## Prerequisites

- Azure subscription with the following providers registered: `Microsoft.ContainerService`, `Microsoft.Monitor`, `Microsoft.AlertsManagement`, `Microsoft.Insights`, `Microsoft.Dashboard`.
- An AKS cluster using managed identity.
- Chosen region that satisfies Azure Monitor workspace and AKS region pairing rules.
- [Terraform 1.6+](https://developer.hashicorp.com/terraform/downloads) and the Azure CLI installed locally.

## Deploy Core Platform with Terraform

```bash
cd infra
terraform init
terraform apply \
  -var 'rg_name=rg-aks-o11y' \
  -var 'location=eastus' \
  -var 'name=aks-o11y'
```

This creates:

- Resource group
- Azure Monitor workspace (Prometheus)
- Log Analytics workspace
- Managed Grafana instance and RBAC
- AKS cluster with Managed Prometheus enabled
- Container Insights (AMA) extension

### Enabling Managed Prometheus on an Existing Cluster

```bash
az aks update -g <rg> -n <cluster> \
  --enable-azure-monitor-metrics \
  --azure-monitor-workspace-resource-id <amw-id> \
  --ksm-metric-labels-allow-list "namespaces=[kubernetes_io_metadata_name]" \
  --ksm-metric-annotations-allow-list "pods=[prometheus.io/scrape,prometheus.io/port,prometheus.io/path]"
```

## Deploy Demo Application and Optional Scrape Config

```bash
kubectl apply -f k8s/demo-app.yaml
# Optional custom scrape configuration
kubectl apply -f k8s/ama-metrics-prometheus-config.yaml
```

## Grafana

1. Open the Managed Grafana endpoint (output from Terraform).
2. Add a Prometheus data source pointing to the Azure Monitor workspace query endpoint and choose **Azure Auth**.
3. Import the dashboard JSON in `grafana/dashboards/slo-api.json` to visualize SLO metrics.

## Alerting

After the core platform is deployed, create alert rules:

```bash
cd alerts
terraform init
terraform apply \
  -var 'name=aks-o11y' \
  -var 'location=eastus' \
  -var 'resource_group_name=rg-aks-o11y' \
  -var 'monitor_workspace_id=<amw-id>' \
  -var 'log_analytics_workspace_id=<law-id>' \
  -var 'action_group_id=<action-group-id>'
```

- `prom-rule-group.tf` provisions Prometheus alert and recording rules.
- `log-alerts.tf` sets up log-based alerts (e.g., CrashLoopBackOff) using KQL queries.

## Cost and Data-Volume Guardrails

- Managed Prometheus defaults to minimal ingestion; expand only as needed.
- Container Insights uses `ContainerLogV2` schema; apply Basic table plan where appropriate.
- Tune log collection through the MSCI data collection rule.

## Validation & Troubleshooting

```bash
# Confirm Managed Prometheus enabled
az aks show -g <rg> -n <cluster> --query "azureMonitorProfile" -o yaml

# Check metrics pods
kubectl get pods -n kube-system | grep ama-metrics

# View scrape targets
kubectl logs -n kube-system deploy/ama-metrics | head -n 100
```

If logs are missing, ensure the `azuremonitor-containers` extension is installed and that the `ContainerLogV2` tables are ingested in Log Analytics.

## Example SLO Policy

- **Availability:** ≥ 99.9% monthly (`1 - 5xx_rate / total_rate`)
- **Latency:** 95th percentile ≤ 300 ms over 30 days
- **Saturation:** Node CPU < 80% sustained

Multi-window, multi-burn alerts can be configured using additional rules in the Prometheus rule group.

## How to Run the Project

1. Deploy infrastructure with Terraform (`/infra`).
2. Enable Managed Prometheus on existing clusters if needed.
3. Deploy Kubernetes manifests (`/k8s`).
4. Configure Grafana and import dashboards (`/grafana`).
5. Provision alert rules (`/alerts`).
6. Validate metrics and logs using the runbook above.

