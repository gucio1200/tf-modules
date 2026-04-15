output "federated_identity_credential_ids" {
  description = "A map of federated identity credential names to their resource IDs."
  value       = module.federated_identity_credential.ids
}

output "federated_identity_credential_names" {
  description = "A map of federated identity credential names to their names."
  value       = module.federated_identity_credential.names
}
