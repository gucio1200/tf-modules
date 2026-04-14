locals {
  # Create a flat list of all assignments, expanding those with a list of principal_ids, role definitions, and/or scopes
  flat_assignments = flatten([
    for k, v in var.assignments : [
      for p_idx, pid in(
        try(v.principal_id, null) != null ? try(tolist(v.principal_id), [v.principal_id]) :
        var.default_principal_id != null ? [var.default_principal_id] : []
        ) : [
        for r_idx, role in(
          try(v.role_definition_name, null) != null ? try(tolist(v.role_definition_name), [v.role_definition_name]) :
          try(v.role_definition_id, null) != null ? try(tolist(v.role_definition_id), [v.role_definition_id]) : []
          ) : [
          for s_idx, s in try(tolist(v.scope), [v.scope]) : {
            # Using indices == 0 ensures backward compatibility (preventing recreation of existing resources)
            # if a user changes a single string into a list.
            key                              = "${k}${p_idx == 0 ? "" : "-${p_idx}"}${r_idx == 0 ? "" : "-r${r_idx}"}${s_idx == 0 ? "" : "-s${s_idx}"}"
            principal_id                     = pid
            scope                            = s
            role_definition_name             = try(v.role_definition_name, null) != null ? role : null
            role_definition_id               = try(v.role_definition_id, null) != null ? role : null
            description                      = try(v.description, null)
            skip_service_principal_aad_check = try(v.skip_service_principal_aad_check, false)
          }
        ]
      ]
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
