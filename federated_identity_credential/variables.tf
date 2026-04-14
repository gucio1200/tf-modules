variable "credentials" {
  description = "A list of objects, each describing an azurerm_federated_identity_credential resource."
  type = list(object({
    name                      = string
    user_assigned_identity_id = optional(string)
    issuer                    = optional(string)
    namespace                 = string
    audience                  = optional(string)
  }))
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
