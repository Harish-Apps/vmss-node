variable "project_name" { type = string }
variable "env" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "sql_server_id" { type = string }

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${var.env}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "${var.project_name}-${var.env}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${var.project_name}-${var.env}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = var.sql_server_id
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address
}
