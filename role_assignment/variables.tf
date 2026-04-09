variable "assignments" {
  description = "A list of objects, each describing an azurerm_role_assignment resource."
  type = list(object({
    principal_id                     = optional(string) # The Object ID of the principal (user, group, service principal, managed identity) to assign the role to. If not provided, `var.default_principal_id` will be used.
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
      assignment if lookup(assignment, "principal_id", null) == null && var.default_principal_id == null
    ]) == 0
    error_message = "Each assignment must provide a 'principal_id' or a 'default_principal_id' must be set for the module."
  }
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
