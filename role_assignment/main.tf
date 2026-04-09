resource "azurerm_role_assignment" "this" {
  for_each = { for r in var.assignments : "${r.principal_id}-${r.scope}-${coalesce(r.role_definition_name, r.role_definition_id)}" => r } # Unique key for each assignment

  scope                            = each.value.scope
  role_definition_name             = lookup(each.value, "role_definition_name", null)
  role_definition_id               = lookup(each.value, "role_definition_id", null)
  principal_id                     = each.value.principal_id
  description                      = lookup(each.value, "description", null)
  skip_service_principal_aad_check = lookup(each.value, "skip_service_principal_aad_check", false)

  # Ensure either role_definition_name or role_definition_id is provided, but not both
  dynamic "validation" {
    for_each = [(lookup(each.value, "role_definition_name", null) != null && lookup(each.value, "role_definition_id", null) != null)]
    content {
      condition     = !validation.value
      error_message = "Cannot specify both 'role_definition_name' and 'role_definition_id'. Please provide only one."
    }
  }
  dynamic "validation" {
    for_each = [(lookup(each.value, "role_definition_name", null) == null && lookup(each.value, "role_definition_id", null) == null)]
    content {
      condition     = !validation.value
      error_message = "Must specify either 'role_definition_name' or 'role_definition_id'."
    }
  }
}
