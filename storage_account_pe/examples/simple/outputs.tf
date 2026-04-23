output "private_endpoints" {
  description = "A map of Private Endpoints created by the module."
  value       = module.storage_pe.private_endpoints
}
