locals {
  pe_combinations = flatten([
    for sa in var.storage_accounts : [
      for sub in sa.subresource_names : {
        name        = split("/", sa.id)[8]
        key         = "${split("/", sa.id)[8]}-${sub}"
        id          = sa.id
        subresource = sub
        tags        = sa.tags
      }
    ]
  ])
  pe_map = { for item in local.pe_combinations : item.key => item }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"

  for_each = local.pe_map

  suffix = [each.value.name, each.value.subresource]
}

resource "azurerm_private_endpoint" "this" {
  for_each                      = local.pe_map
  name                          = module.naming[each.key].private_endpoint.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = module.naming[each.key].network_interface.name

  tags = merge(var.tags, each.value.tags)

  private_service_connection {
    name                           = "${module.naming[each.key].private_endpoint.name}-connection"
    private_connection_resource_id = each.value.id
    is_manual_connection           = false

    subresource_names = [each.value.subresource]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(lookup(var.private_dns_zone_ids, each.value.subresource, [])) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids[each.value.subresource]
    }
  }
}
