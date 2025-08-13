output "resource_group"   { value = azurerm_resource_group.rg.name }
output "workspace_name"   { value = azurerm_machine_learning_workspace.aml.name }
output "compute_cluster"  { value = azurerm_machine_learning_compute_cluster.cpu.name }
output "location"         { value = azurerm_resource_group.rg.location }
