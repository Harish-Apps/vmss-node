variable "region" {
  description = "Azure region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "address_space" {
  description = "Address space for the spoke VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet names to address prefixes"
  type        = map(string)
}

variable "hub_vnet_id" {
  description = "ID of the hub virtual network"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub resource group name"
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  type        = string
}
