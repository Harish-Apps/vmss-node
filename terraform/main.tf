locals {
  hub_configs = { for r, cfg in var.regions : r => cfg.hub }
  spoke_configs = {
    for r, cfg in var.regions :
    for env, spoke in cfg.spokes :
    "${r}-${env}" => merge(spoke, { region = r, env = env })
  }
}

module "hub" {
  for_each      = local.hub_configs
  source        = "./modules/hub"
  region        = each.key
  address_space = each.value.address_space
  subnets       = each.value.subnets
}

module "spoke" {
  for_each = local.spoke_configs
  source   = "./modules/spoke"
  region   = each.value.region
  env      = each.value.env
  address_space = each.value.address_space
  subnets       = each.value.subnets
  hub_vnet_id             = module.hub[each.value.region].vnet_id
  hub_vnet_name           = "vnet-hub-${each.value.region}"
  hub_resource_group_name = "rg-network-hub-${each.value.region}"
  firewall_private_ip     = module.hub[each.value.region].firewall_private_ip
}
