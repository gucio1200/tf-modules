output "federated_identity_credential_ids" {
  description = "A map of configurations to their respective federated identity credential IDs."
  value       = { for k, v in module.federated_identity_credential : k => v.ids }
}

output "role_assignment_ids" {
  description = "A map of configurations to their respective role assignment IDs."
  value       = { for k, v in module.role_assignment : k => v.ids }
}
