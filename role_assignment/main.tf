resource "azurerm_role_assignment" "this" {
  for_each = { for r in var.assignments : "${coalesce(r.principal_id, var.default_principal_id)}-${r.scope}-${coalesce(r.role_definition_name, r.role_definition_id)}" => r }

  scope                            = each.value.scope
  role_definition_name             = lookup(each.value, "role_definition_name", null)
  role_definition_id               = lookup(each.value, "role_definition_id", null)
  principal_id                     = coalesce(each.value.principal_id, var.default_principal_id)
  description                      = lookup(each.value, "description", null)
  skip_service_principal_aad_check = lookup(each.value, "skip_service_principal_aad_check", false)
}
