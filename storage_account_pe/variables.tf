variable "location" {
  description = "The Azure region where the Private Endpoints will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Private Endpoints will be created."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet where the Private Endpoints will be created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "A map of Private DNS Zone IDs, where the key is the subresource type (e.g., 'blob', 'file')."
  type        = map(list(string))
  default     = {}
}

variable "storage_accounts" {
  description = "A list of objects containing storage account details for PE creation."
  type = list(object({
    id                = string
    subresource_names = optional(list(string), ["blob"])
    tags              = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Default tags to apply to all Private Endpoints."
  type        = map(string)
  default     = {}
}

