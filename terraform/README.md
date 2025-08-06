# Terraform deployment

This directory contains Terraform modules and examples for deploying infrastructure components.

## Deploying application servers

### Prerequisites

Set the following environment variables for Azure authentication and remote state access:

- `ARM_SUBSCRIPTION_ID`
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `TF_BACKEND_RESOURCE_GROUP`
- `TF_BACKEND_STORAGE_ACCOUNT`
- `TF_BACKEND_CONTAINER`
- `TF_BACKEND_KEY`

The backend is configured with an `azurerm` remote state:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = var.backend_key
  }
}
```

### Networking and security considerations

- Firewall or Azure Firewall rules should permit only the required inbound and outbound ports for the application.
- Network Security Groups (NSGs) must allow traffic from approved sources to the app subnet and block unauthorized access.
- Route tables should forward traffic to the correct next hop (for example, the firewall) and include user-defined routes for internet egress if needed.
- Private or public DNS zones must resolve application hostnames to the addresses within the spoke subnet.

### Example deployment

The following snippet deploys a Linux VM into the application subnet of the `dev-eastus` spoke:

```hcl
resource "azurerm_network_interface" "app" {
  name                = "appnic"
  location            = module.spoke["dev-eastus"].location
  resource_group_name = module.spoke["dev-eastus"].resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.spoke["dev-eastus"].subnet_ids["app"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                = "app-vm"
  location            = module.spoke["dev-eastus"].location
  resource_group_name = module.spoke["dev-eastus"].resource_group_name
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.app.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
```

### Post-deployment verification

- Confirm connectivity from management or peer networks to the new server.
- Configure monitoring and logging, such as Log Analytics or App Insights, and ensure metrics are being collected.

