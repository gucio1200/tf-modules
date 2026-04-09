output "ids" {
  description = "A map of generated unique keys to their role assignment resource IDs."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}
