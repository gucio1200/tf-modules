variable "assignments" {
  description = "A list of objects, each describing an azurerm_role_assignment resource."
  type = list(object({
    principal_id                     = string
    scope                            = string
    role_definition_name             = optional(string)
    role_definition_id               = optional(string)
    description                      = optional(string, null)
    skip_service_principal_aad_check = optional(bool, false)
  }))
  validation {
    condition = all([
      for assignment in var.assignments :
      (lookup(assignment, "role_definition_name", null) != null || lookup(assignment, "role_definition_id", null) != null) &&
      !(lookup(assignment, "role_definition_name", null) != null && lookup(assignment, "role_definition_id", null) != null)
    ])
    error_message = "Each assignment must provide exactly one of 'role_definition_name' or 'role_definition_id'."
  }
}
