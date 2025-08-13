resource "azurerm_resource_group" "o11y" {
  name     = var.rg_name
  location = var.location
}

# Azure Monitor workspace (Prometheus data store)
resource "azurerm_monitor_workspace" "amw" {
  name                          = "${var.name}-amw"
  location                      = azurerm_resource_group.o11y.location
  resource_group_name           = azurerm_resource_group.o11y.name
  public_network_access_enabled = true
  tags                          = var.tags
}

# Log Analytics workspace for Container Insights
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name}-law"
  location            = azurerm_resource_group.o11y.location
  resource_group_name = azurerm_resource_group.o11y.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Managed Grafana
resource "azurerm_dashboard_grafana" "mg" {
  name                = "${var.name}-mgraf"
  location            = azurerm_resource_group.o11y.location
  resource_group_name = azurerm_resource_group.o11y.name
  zone_redundancy_enabled = false
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# Allow Grafana to read Prometheus in the AM workspace
resource "azurerm_role_assignment" "mg_to_amw_reader" {
  scope                = azurerm_monitor_workspace.amw.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.mg.identity[0].principal_id
}

# Create an AKS cluster with Managed Prometheus enabled
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.o11y.location
  resource_group_name = azurerm_resource_group.o11y.name
  dns_prefix          = "${var.name}-dns"

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D4ds_v5"
    node_count = 3
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Azure Monitor managed service for Prometheus
  monitor_metrics {
    labels_allowed      = "namespaces=[kubernetes_io_metadata_name]"
    annotations_allowed = "pods=[prometheus.io/scrape,prometheus.io/port,prometheus.io/path]"
  }
}

# Container Insights using Azure Monitor Agent
resource "azurerm_kubernetes_cluster_extension" "ci" {
  name           = "azuremonitor-containers"
  cluster_id     = azurerm_kubernetes_cluster.aks.id
  extension_type = "azuremonitor-containers"
  release_train  = "Stable"
}
