variable "assignments" {
  description = "A map of objects, each describing an azurerm_role_assignment resource. The map key should be a stable, plan-time known string (like the role name)."
  type = map(object({
    principal_id                     = optional(any)
    scope                            = string
    role_definition_name             = optional(string)
    role_definition_id               = optional(string)
    description                      = optional(string, null)
    skip_service_principal_aad_check = optional(bool, false)
  }))

  validation {
    condition = length([
      for v in var.assignments :
      v if(v.role_definition_name != null ? 1 : 0) + (v.role_definition_id != null ? 1 : 0) != 1
    ]) == 0
    error_message = "Each assignment must provide exactly one of 'role_definition_name' or 'role_definition_id'."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if v.principal_id == null && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide 'principal_id' (as a string or list) or a 'default_principal_id' must be set for the module."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
