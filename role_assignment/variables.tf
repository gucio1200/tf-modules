variable "assignments" {
  description = "A map of objects, each describing an azurerm_role_assignment resource. The map key should be a stable, plan-time known string (like the role name)."
  type        = any

  validation {
    condition = length([
      for v in var.assignments :
      v if(try(v.role_definition_name, null) != null ? 1 : 0) + (try(v.role_definition_id, null) != null ? 1 : 0) != 1
    ]) == 0
    error_message = "Each assignment must provide either the 'role_definition_name' or 'role_definition_id' property, but not both. The value can be a single string or a list of strings."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if try(v.principal_id, null) == null && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide a 'principal_id' (can be a single string or a list of strings) or a 'default_principal_id' must be set for the module."
  }

  validation {
    condition = length([
      for v in var.assignments :
      v if try(v.scope, null) == null || length(try(tolist(v.scope), [v.scope])) == 0
    ]) == 0
    error_message = "Each assignment must provide a valid 'scope' (can be a single string or a list of strings)."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
