resource "azurerm_role_assignment" "this" {
  for_each = var.assignments

  scope                            = each.value.scope
  role_definition_name             = lookup(each.value, "role_definition_name", null)
  role_definition_id               = lookup(each.value, "role_definition_id", null)
  principal_id                     = coalesce(each.value.principal_id, var.default_principal_id)
  description                      = lookup(each.value, "description", null)
  skip_service_principal_aad_check = lookup(each.value, "skip_service_principal_aad_check", false)
}
