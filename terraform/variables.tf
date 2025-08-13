variable "prefix" {
  type    = string
  default = "llmdemo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}

# Compute settings
variable "vm_size" {
  type    = string
  default = "Standard_D2_v2" # CPU SKU from Dv2 family
}

variable "vm_priority" {
  type    = string
  default = "Dedicated" # or "LowPriority" for spot VMs
}

variable "max_nodes" {
  type    = number
  default = 1 # bump to 2+ for DDP
}

# ACR SKU
variable "acr_sku" {
  type    = string
  default = "Premium"
}
