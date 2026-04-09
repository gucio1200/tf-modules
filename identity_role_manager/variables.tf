variable "workload_configs" {
  description = "A map of predefined configurations to enable. The key is the configuration name (e.g., 'app-workload-1'). The value is an object containing optional variables to override defaults for that specific configuration."
  type = map(object({
    scope                     = optional(string)
    principal_id              = optional(string)
    issuer_url                = optional(string)
    user_assigned_identity_id = optional(string)
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
