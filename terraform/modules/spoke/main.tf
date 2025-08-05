resource "azurerm_resource_group" "spoke" {
  name     = "rg-network-${var.env}-${var.region}"
  location = var.region
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.env}-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each             = var.subnets
  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = "nsg-${each.key}-${var.env}-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.spoke.name

  security_rule {
    name                       = "default-deny"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each                  = azurerm_subnet.spoke_subnets
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg[replace(each.key, "subnet-", "")].id
}

resource "azurerm_route_table" "spoke" {
  name                = "rt-${var.env}-${var.region}"
  location            = var.region
  resource_group_name = azurerm_resource_group.spoke.name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
  for_each       = azurerm_subnet.spoke_subnets
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${var.env}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "vnet_id" {
  value = azurerm_virtual_network.spoke.id
}
