variable "assignments" {
  description = "A map of objects, each describing an azurerm_role_assignment resource. The map key should be a stable, plan-time known string (like the role name)."
  type = map(object({
    principal_id                     = optional(any)
    scope                            = any
    role_definition_name             = optional(any)
    role_definition_id               = optional(any)
    description                      = optional(string, null)
    skip_service_principal_aad_check = optional(bool, false)
  }))

  validation {
    condition = length([
      for v in var.assignments :
      v if(v.role_definition_name != null ? 1 : 0) + (v.role_definition_id != null ? 1 : 0) != 1
    ]) == 0
    error_message = "Each assignment must provide either the 'role_definition_name' or 'role_definition_id' property, but not both. The value can be a single string or a list of strings."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if v.principal_id == null && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide a 'principal_id' (can be a single string or a list of strings) or a 'default_principal_id' must be set for the module."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if v.scope == null || length(try(tolist(v.scope), [v.scope])) == 0
    ]) == 0
    error_message = "Each assignment must provide a valid 'scope' (can be a single string or a list of strings)."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
