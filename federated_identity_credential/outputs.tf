output "ids" {
  description = "A map of federated identity credential names to their resource IDs."
  value       = { for k, v in azurerm_federated_identity_credential.this : k => v.id }
}

output "names" {
  description = "A map of federated identity credential names to their names."
  value       = { for k, v in azurerm_federated_identity_credential.this : k => v.name }
}
