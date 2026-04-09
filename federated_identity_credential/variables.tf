variable "credentials" {
  description = "A list of objects, each describing an azurerm_federated_identity_credential resource."
  type = list(object({
    name                      = string
    user_assigned_identity_id = string
    issuer                    = string
    subject                   = string
    audience                  = string
    description               = optional(string, null)
  }))
}
