variable "region" {
  description = "Azure region for the hub"
  type        = string
}

variable "address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet names to address prefixes"
  type        = map(string)
}
