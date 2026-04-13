variable "assignments" {
  description = "A map of objects, each describing an azurerm_role_assignment resource. The map key should be a stable, plan-time known string (like the role name)."
  type = map(object({
    principal_id                     = optional(string)
    principal_ids                    = optional(list(string), [])
    scope                            = string
    role_definition_name             = optional(string)
    role_definition_id               = optional(string)
    description                      = optional(string, null)
    skip_service_principal_aad_check = optional(bool, false)
  }))
  validation {
    condition = length([
      for assignment in var.assignments :
      assignment if !((lookup(assignment, "role_definition_name", null) != null || lookup(assignment, "role_definition_id", null) != null) &&
      !(lookup(assignment, "role_definition_name", null) != null && lookup(assignment, "role_definition_id", null) != null))
    ]) == 0
    error_message = "Each assignment must provide exactly one of 'role_definition_name' or 'role_definition_id'."
  }
  validation {
    condition = length([
      for assignment in var.assignments :
      assignment if lookup(assignment, "principal_id", null) == null && length(coalesce(lookup(assignment, "principal_ids", []), [])) == 0 && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide a 'principal_id', 'principal_ids', or a 'default_principal_id' must be set for the module."
  }
  validation {
    condition = length([
      for assignment in var.assignments :
      assignment if lookup(assignment, "principal_id", null) != null && length(coalesce(lookup(assignment, "principal_ids", []), [])) > 0
    ]) == 0
    error_message = "Each assignment must provide either 'principal_id' or 'principal_ids', not both."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
