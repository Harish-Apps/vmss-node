variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "dhaapps"
}

variable "env" {
  description = "Environment (dev|test|prod)"
  type        = string
  default     = "dev"
}

variable "location_primary" {
  description = "Primary Azure region"
  type        = string
  default     = "centralindia"
}

variable "location_dr" {
  description = "DR Azure region"
  type        = string
  default     = "centralindia"
}

variable "sql_sku_tier" {
  description = "SQL SKU tier (GeneralPurpose|BusinessCritical)"
  type        = string
  default     = "GeneralPurpose"
}

variable "compute_model" {
  description = "Compute model (serverless|provisioned)"
  type        = string
  default     = "serverless"
}

variable "enable_ltr" {
  description = "Enable long term retention"
  type        = bool
  default     = false
}

variable "enable_failover_group" {
  description = "Enable auto-failover group"
  type        = bool
  default     = false
}

variable "enable_defender" {
  description = "Enable Defender for SQL"
  type        = bool
  default     = true
}

variable "enable_auditing" {
  description = "Enable auditing to Log Analytics"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  type        = string
  default     = "log"
}

variable "aad_admin_login" {
  description = "AAD administrator login"
  type        = string
  default     = "azureuser"
}

variable "aad_admin_object_id" {
  description = "AAD administrator object ID"
  type        = string
  default     = "7dd8781a-5f8b-4b48-b0ab-06ce7e69e18e"
}
