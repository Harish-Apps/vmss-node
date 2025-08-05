resource "azurerm_resource_group" "hub" {
  name     = "rg-network-hub-${var.region}"
  location = var.region
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "hub_subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-azfw-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "azfw-hub-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_subnets["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_lb" "internal" {
  name                = "alb-hub-internal-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "frontend"
    subnet_id = azurerm_subnet.hub_subnets["LoadBalancerSubnet"].id
  }
}

output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
