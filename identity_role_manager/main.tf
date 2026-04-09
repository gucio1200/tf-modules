locals {
  # DYNAMIC LOGIC: Automatically loop over user inputs and map variables into the predefined configurations
  active_configs = {
    for k, config in var.workload_configs : k => {

      federated_identity_credentials = [
        for fic in try(local.predefined_configs[k].federated_identity_credentials, []) : {
          name                      = fic.name
          namespace                 = fic.namespace
          issuer                    = config.issuer_url != null ? config.issuer_url : try(fic.issuer, null)
          user_assigned_identity_id = config.user_assigned_identity_id != null ? config.user_assigned_identity_id : try(fic.user_assigned_identity_id, null)
          audience                  = try(fic.audience, null)
        }
      ]

      role_assignments = [
        for ra in try(local.predefined_configs[k].role_assignments, []) : {
          scope                            = config.scope
          role_definition_name             = try(ra.role_definition_name, null)
          role_definition_id               = try(ra.role_definition_id, null)
          principal_id                     = config.principal_id != null ? config.principal_id : try(ra.principal_id, null)
          description                      = try(ra.description, null)
          skip_service_principal_aad_check = try(ra.skip_service_principal_aad_check, false)
        }
      ]
    }
    # Only process configurations that actually exist in our predefined list
    if contains(keys(local.predefined_configs), k)
  }
}

module "federated_identity_credential" {
  source = "../federated_identity_credential"

  for_each = {
    for k, v in local.active_configs : k => v
    if length(try(v.federated_identity_credentials, [])) > 0
  }

  credentials = each.value.federated_identity_credentials

  default_issuer                    = var.default_issuer
  default_audience                  = var.default_audience
  default_user_assigned_identity_id = var.default_user_assigned_identity_id
}

module "role_assignment" {
  source = "../role_assignment"

  for_each = {
    for k, v in local.active_configs : k => v
    if length(try(v.role_assignments, [])) > 0
  }

  assignments = each.value.role_assignments

  default_principal_id = var.default_principal_id
}
