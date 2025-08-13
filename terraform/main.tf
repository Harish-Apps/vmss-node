# Current client (for KV tenant id)
data "azurerm_client_config" "current" {}

# Random suffix for globally-unique names
resource "random_integer" "suffix" {
  min = 10000000
  max = 99999999
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
}

# Application Insights
resource "azurerm_application_insights" "appi" {
  name                = "${var.prefix}${var.environment}${random_integer.suffix.result}-appi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                     = "${var.prefix}${var.environment}${random_integer.suffix.result}kv"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "premium"
  purge_protection_enabled = false
}

# Storage (workspace default datastore)
resource "azurerm_storage_account" "sa" {
  name                            = "${var.prefix}${var.environment}${random_integer.suffix.result}st"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}${var.environment}${random_integer.suffix.result}cr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.acr_sku
  admin_enabled       = true
}

# Azure ML Workspace (v2)
resource "azurerm_machine_learning_workspace" "aml" {
  name                          = "${var.prefix}-${var.environment}-mlw"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  application_insights_id       = azurerm_application_insights.appi.id
  key_vault_id                  = azurerm_key_vault.kv.id
  storage_account_id            = azurerm_storage_account.sa.id
  container_registry_id         = azurerm_container_registry.acr.id
  public_network_access_enabled = true

  identity { type = "SystemAssigned" }
}

# GPU Compute Cluster (AmlCompute)
resource "azurerm_machine_learning_compute_cluster" "gpu" {
  name                          = "${var.prefix}-${var.environment}-gpucc"
  location                      = azurerm_resource_group.rg.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml.id

  vm_priority = var.vm_priority                    # "LowPriority" (spot) or "Dedicated"
  vm_size     = var.gpu_vm_size

  # Scale to zero when idle (W3C duration, e.g. PT10M = 10 minutes)
  scale_settings {
    min_node_count                       = 0
    max_node_count                       = var.max_nodes
    scale_down_nodes_after_idle_duration = "PT10M"
  }

  # Optional: enable SSH to nodes (requires admin + key/password)
  # ssh {
  #   admin_username = "azureuser"
  #   key_value      = file("~/.ssh/id_rsa.pub")
  # }

  tags = {
    project = "llm-train-platform"
    env     = var.environment
  }
}
