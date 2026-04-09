locals {
  # DYNAMIC LOGIC: Automatically loop over user inputs and map variables into the predefined configurations
  active_configs = {
    for k, config in var.workload_configs : k => {

      federated_identity_credentials = [
        for fic in try(local.predefined_configs[k].federated_identity_credentials, []) : {
          name                      = fic.name
          namespace                 = fic.namespace
          issuer                    = config.issuer_url != null ? config.issuer_url : try(fic.issuer, null)
          user_assigned_identity_id = config.custom_user_assigned_identity_id != null ? config.custom_user_assigned_identity_id : try(fic.user_assigned_identity_id, null)
          audience                  = try(fic.audience, null)
          description               = try(fic.description, null)
        }
      ]

      # Combine the predefined roles with any extra roles passed in dynamically via `additional_role_assignments`
      role_assignments = concat(
        [
          for ra in try(local.predefined_configs[k].role_assignments, []) : {
            scope                            = config.scope
            role_definition_name             = try(ra.role_definition_name, null)
            role_definition_id               = try(ra.role_definition_id, null)
            principal_id                     = config.principal_id != null ? config.principal_id : try(ra.principal_id, null)
            description                      = try(ra.description, null)
            skip_service_principal_aad_check = try(ra.skip_service_principal_aad_check, false)
          }
        ],
        [
          for extra_ra in config.additional_role_assignments : {
            scope                = extra_ra.scope
            role_definition_name = extra_ra.role_definition_name
            role_definition_id   = extra_ra.role_definition_id
            # Fallback to the workload's override principal_id, otherwise use the one defined in the extra role, otherwise null
            principal_id                     = extra_ra.principal_id != null ? extra_ra.principal_id : (config.principal_id != null ? config.principal_id : null)
            description                      = extra_ra.description
            skip_service_principal_aad_check = extra_ra.skip_service_principal_aad_check
          }
        ]
      )
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
