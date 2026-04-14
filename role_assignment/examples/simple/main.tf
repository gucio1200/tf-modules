provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}

locals {
  name     = "ex-${basename(path.cwd)}"
  location = "westeurope"

  tags = {
    Example = local.name
    Module  = "role_assignment"
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "secondary" {
  name     = "rg-${local.name}-secondary"
  location = local.location
  tags     = local.tags
}

################################################################################
# Role Assignment Module
################################################################################

module "role_assignments" {
  source = "../../"

  # We can set a default principal ID to be used when one is not explicitly provided in the map
  default_principal_id = data.azurerm_client_config.current.object_id

  assignments = {
    # 1. Simple assignment (Single scope, single role, implicit default principal)
    "rg-reader" = {
      scope                = [azurerm_resource_group.this.id]
      role_definition_name = ["Reader"]
    }

    # 2. Explicit assignment (Single scope, single role, explicit principal)
    "rg-contributor" = {
      scope                = [azurerm_resource_group.this.id]
      role_definition_name = ["Contributor"]
      principal_id         = [data.azurerm_client_config.current.object_id]
    }

    # 3. Matrix assignment (Multiple scopes, multiple roles, single or multiple principals)
    "rg-matrix" = {
      scope = [
        azurerm_resource_group.this.id,
        azurerm_resource_group.secondary.id
      ]
      role_definition_name = [
        "Key Vault Secrets Officer",
        "Storage Blob Data Contributor"
      ]
      principal_id = [
        data.azurerm_client_config.current.object_id
        # You could add more principal IDs here
      ]
    }

    # 4. Using role_definition_id instead of role_definition_name
    "custom-role-by-id" = {
      scope = [azurerm_resource_group.this.id]
      # Using a well-known built-in role ID (e.g., Reader role ID) as an example
      role_definition_id = ["/subscriptions/${data.azurerm_subscription.primary.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"]
      principal_id       = [data.azurerm_client_config.current.object_id]
    }

    # 5. Using all optional attributes (description, skip_service_principal_aad_check)
    "rg-full-options" = {
      scope                            = [azurerm_resource_group.this.id]
      role_definition_name             = ["Tag Contributor"]
      principal_id                     = [data.azurerm_client_config.current.object_id]
      description                      = "Allows managing tags on the resource group"
      skip_service_principal_aad_check = true
    }
  }
}

output "assignments" {
  description = "The generated role assignments"
  value       = module.role_assignments.assignments
}
