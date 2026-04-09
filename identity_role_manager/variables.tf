variable "workload_configs" {
  description = "A map of predefined configurations to enable. The key is the configuration name (e.g., 'app-workload-1'). The value is an object containing optional variables to override defaults for that specific configuration."
  type = map(object({
    scope                            = optional(string)
    principal_id                     = optional(string)
    issuer_url                       = optional(string)
    custom_user_assigned_identity_id = optional(string)

    additional_role_assignments = optional(list(object({
      scope                            = string
      role_definition_name             = optional(string)
      role_definition_id               = optional(string)
      principal_id                     = optional(string)
      description                      = optional(string)
      skip_service_principal_aad_check = optional(bool, false)
    })), [])
  }))
  default = {}
}

variable "default_issuer" {
  description = "Optional. A default OIDC issuer if not specified per-credential."
  type        = string
  default     = null
}

variable "default_audience" {
  description = "Optional. A default audience value to use for credentials if not specified per-credential."
  type        = string
  default     = "api://AzureADTokenExchange"
}

variable "default_user_assigned_identity_id" {
  description = "Optional. A default user_assigned_identity_id if not specified per-credential."
  type        = string
  default     = null
}

variable "default_principal_id" {
  description = "Optional. A default Principal ID to use for assignments if not specified per-assignment."
  type        = string
  default     = null
}
