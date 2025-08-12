variable "project_name" { type = string }
variable "env" { type = string }
variable "location_primary" { type = string }
variable "location_dr" { type = string }
variable "resource_group_name" { type = string }
variable "dr_resource_group_name" { type = string }
variable "sql_sku_tier" { type = string }
variable "compute_model" { type = string }
variable "enable_ltr" { type = bool }
variable "enable_failover_group" { type = bool }
variable "enable_defender" { type = bool }
variable "enable_auditing" { type = bool }
variable "log_analytics_workspace_id" { type = string }
variable "aad_admin_login" { type = string }
variable "aad_admin_object_id" { type = string }

resource "azurerm_mssql_server" "primary" {
  name                         = "${var.project_name}-${var.env}-sql"
  resource_group_name          = var.resource_group_name
  location                     = var.location_primary
  version                      = "12.0"
  public_network_access_enabled = false

  azuread_administrator {
    login_username = var.aad_admin_login
    object_id      = var.aad_admin_object_id
  }
}

resource "azurerm_mssql_server" "secondary" {
  count                       = var.enable_failover_group ? 1 : 0
  name                        = "${var.project_name}-${var.env}-sql-dr"
  resource_group_name         = var.dr_resource_group_name
  location                    = var.location_dr
  version                     = "12.0"
  public_network_access_enabled = false

  azuread_administrator {
    login_username = var.aad_admin_login
    object_id      = var.aad_admin_object_id
  }
}

resource "azurerm_mssql_server_automatic_tuning" "primary" {
  server_id     = azurerm_mssql_server.primary.id
  desired_state = "Auto"
}

resource "azurerm_mssql_server_automatic_tuning" "secondary" {
  count         = var.enable_failover_group ? 1 : 0
  server_id     = azurerm_mssql_server.secondary[0].id
  desired_state = "Auto"
}

locals {
  sku_name = var.sql_sku_tier == "BusinessCritical" ? "BC_Gen5_2" : "GP_Gen5_2"
}

resource "azurerm_mssql_database" "db" {
  name      = "${var.project_name}-${var.env}-db"
  server_id = azurerm_mssql_server.primary.id
  sku_name  = local.sku_name
  auto_pause_delay_in_minutes = var.compute_model == "serverless" ? 60 : null
  min_capacity = var.compute_model == "serverless" ? 0.5 : null
}

resource "azurerm_monitor_diagnostic_setting" "sql" {
  name                       = "${var.project_name}-${var.env}-diag"
  target_resource_id         = azurerm_mssql_server.primary.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "SQLInsights"
    enabled  = true
  }

  log {
    category = "AutomaticTuning"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  count                      = var.enable_auditing ? 1 : 0
  server_id                  = azurerm_mssql_server.primary.id
  log_monitoring_enabled     = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_mssql_server_security_alert_policy" "defender" {
  count               = var.enable_defender ? 1 : 0
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.primary.name
  state               = "Enabled"
  email_account_admins = true
}

resource "azurerm_mssql_failover_group" "fog" {
  count               = var.enable_failover_group ? 1 : 0
  name                = "${var.project_name}-${var.env}-fog"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.primary.name

  partner_servers {
    id = azurerm_mssql_server.secondary[0].id
  }

  databases = [azurerm_mssql_database.db.id]
}

resource "azurerm_sql_database_long_term_retention_policy" "ltr" {
  count               = var.enable_ltr ? 1 : 0
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.primary.name
  database_name       = azurerm_mssql_database.db.name
  weekly_retention    = "P1Y"
}

output "server_id" {
  value = azurerm_mssql_server.primary.id
}

output "server_fqdn" {
  value = azurerm_mssql_server.primary.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_mssql_database.db.name
}
