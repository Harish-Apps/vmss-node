output "hub_vnet_ids" {
  value = { for k, m in module.hub : k => m.vnet_id }
}

output "spoke_vnet_ids" {
  value = { for k, m in module.spoke : k => m.vnet_id }
}
