variable "rg_name" {
  description = "Name of the resource group for observability resources"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "name" {
  description = "Base name used for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
