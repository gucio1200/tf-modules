locals {
  # 1. Filter the configurations to only those explicitly enabled in the root module
  enabled_workloads = {
    for workload_name, config in var.workload_configs : workload_name => config
    if contains(keys(local.predefined_configs), workload_name)
  }

  # 2. Build the final maps of Federated Identity Credentials
  active_credentials = {
    for workload_name, config in local.enabled_workloads : workload_name => {
      for fic in try(local.predefined_configs[workload_name].federated_identity_credentials, []) :
      "${workload_name}-${fic.namespace}-${fic.name}" => {
        name                      = fic.name
        namespace                 = fic.namespace
        issuer                    = config.issuer_url != null ? config.issuer_url : try(fic.issuer, null)
        user_assigned_identity_id = config.user_assigned_identity_id != null ? config.user_assigned_identity_id : try(fic.user_assigned_identity_id, null)
        audience                  = try(fic.audience, null)
      }
    }
  }

  # 3. Build the final maps of Role Assignments
  active_roles = {
    for workload_name, config in local.enabled_workloads : workload_name => {
      for ra in try(local.predefined_configs[workload_name].role_assignments, []) :
      "${workload_name}-${coalesce(try(ra.role_definition_name, null), try(ra.role_definition_id, null))}" => {
        scope                            = config.scope
        role_definition_name             = try(ra.role_definition_name, null)
        role_definition_id               = try(ra.role_definition_id, null)
        principal_id                     = config.principal_id != null ? config.principal_id : try(ra.principal_id, null)
        description                      = try(ra.description, null)
        skip_service_principal_aad_check = try(ra.skip_service_principal_aad_check, false)
      }
    }
  }
}

module "federated_identity_credential" {
  source = "../federated_identity_credential"

  for_each = {
    for k, v in local.active_credentials : k => v
    if length(v) > 0
  }

  credentials = each.value

  default_issuer                    = var.default_issuer
  default_audience                  = var.default_audience
  default_user_assigned_identity_id = var.default_user_assigned_identity_id
}

module "role_assignment" {
  source = "../role_assignment"

  for_each = {
    for k, v in local.active_roles : k => v
    if length(v) > 0
  }

  assignments = each.value

  default_principal_id = var.default_principal_id
}
