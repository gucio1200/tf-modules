variable "assignments" {
  description = "A list of objects, each describing an azurerm_role_assignment resource."
  type = list(object({
    principal_id                     = string           # The Object ID of the principal (user, group, service principal, managed identity) to assign the role to.
    scope                            = string           # The scope at which the role assignment applies. e.g., subscription ID, resource group ID, resource ID.
    role_definition_name             = optional(string) # The name of the built-in role to assign (e.g., 'Contributor', 'Reader').
    role_definition_id               = optional(string) # The ID of the custom role definition to assign.
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
