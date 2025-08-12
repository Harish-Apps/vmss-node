terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "${var.project_name}-${var.env}-rg"
  location = var.location_primary
}

resource "azurerm_resource_group" "dr" {
  count    = var.enable_failover_group ? 1 : 0
  name     = "${var.project_name}-${var.env}-dr-rg"
  location = var.location_dr
}

module "sql" {
  source                     = "./modules/sql"
  project_name               = var.project_name
  env                        = var.env
  location_primary           = var.location_primary
  location_dr                = var.location_dr
  resource_group_name        = azurerm_resource_group.primary.name
  dr_resource_group_name     = var.enable_failover_group ? azurerm_resource_group.dr[0].name : ""
  sql_sku_tier               = var.sql_sku_tier
  compute_model              = var.compute_model
  enable_ltr                 = var.enable_ltr
  enable_failover_group      = var.enable_failover_group
  enable_defender            = var.enable_defender
  enable_auditing            = var.enable_auditing
  log_analytics_workspace_id = var.log_analytics_workspace_id
  aad_admin_login            = var.aad_admin_login
  aad_admin_object_id        = var.aad_admin_object_id
}

module "network" {
  source              = "./modules/network"
  project_name        = var.project_name
  env                 = var.env
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.primary.name
  sql_server_id       = module.sql.server_id
}
