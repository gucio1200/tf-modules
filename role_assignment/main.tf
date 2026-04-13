locals {
  # Create a flat list of all assignments, expanding those with a list of principal_ids
  flat_assignments = flatten([
    for k, v in var.assignments : [
      for idx, pid in(
        v.principal_id != null ? try(tolist(v.principal_id), [v.principal_id]) :
        var.default_principal_id != null ? [var.default_principal_id] : []
        ) : {
        # The key combines the original map key and the index if there are multiple principals.
        key                              = length(try(tolist(v.principal_id), [v.principal_id])) > 1 ? "${k}-${idx}" : k
        principal_id                     = pid
        scope                            = v.scope
        role_definition_name             = v.role_definition_name
        role_definition_id               = v.role_definition_id
        description                      = v.description
        skip_service_principal_aad_check = v.skip_service_principal_aad_check
      }
    ]
  ])

  assignment_map = {
    for a in local.flat_assignments : a.key => a
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = local.assignment_map

  scope                            = each.value.scope
  role_definition_name             = each.value.role_definition_name
  role_definition_id               = each.value.role_definition_id
  principal_id                     = each.value.principal_id
  description                      = each.value.description
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}
