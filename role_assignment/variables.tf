variable "assignments" {
  description = "A map of objects, each describing an azurerm_role_assignment resource. The map key should be a stable, plan-time known string (like the role name)."
  type = map(object({
    principal_id                     = optional(list(string))
    scope                            = list(string)
    role_definition_name             = optional(list(string))
    role_definition_id               = optional(list(string))
    description                      = optional(string, null)
    skip_service_principal_aad_check = optional(bool, false)
  }))

  validation {
    condition = length([
      for v in var.assignments :
      v if(v.role_definition_name != null ? 1 : 0) + (v.role_definition_id != null ? 1 : 0) != 1
    ]) == 0
    error_message = "Each assignment must provide either the 'role_definition_name' or 'role_definition_id' property, but not both."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if v.principal_id == null && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide a 'principal_id' (as a list of strings) or a 'default_principal_id' must be set for the module."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if length(v.scope) == 0
    ]) == 0
    error_message = "Each assignment must provide a valid 'scope' (as a list of strings with at least one element)."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
