output "private_endpoints" {
  description = "A map of Private Endpoints created by this module."
  value = {
    for k, v in azurerm_private_endpoint.this : k => {
      id                            = v.id
      name                          = v.name
      custom_network_interface_name = v.custom_network_interface_name
      private_service_connection    = v.private_service_connection
      private_dns_zone_group        = v.private_dns_zone_group
    }
  }
}
