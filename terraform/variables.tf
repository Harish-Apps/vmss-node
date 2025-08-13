variable "prefix"        { type = string  default = "llmdemo" }
variable "environment"   { type = string  default = "dev" }
variable "location"      { type = string  default = "eastus" }

# Compute settings
variable "gpu_vm_size"   { type = string  default = "Standard_NC4as_T4_v3" } # affordable T4
variable "vm_priority"   { type = string  default = "LowPriority" }         # or "Dedicated"
variable "max_nodes"     { type = number  default = 1 }                      # bump to 2+ for DDP

# ACR SKU
variable "acr_sku"       { type = string  default = "Premium" }
