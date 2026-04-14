provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

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
      scope                = azurerm_resource_group.this.id
      role_definition_name = "Reader"
    }

    # 2. Explicit assignment (Single scope, single role, explicit principal)
    "rg-contributor" = {
      scope                = azurerm_resource_group.this.id
      role_definition_name = "Contributor"
      principal_id         = data.azurerm_client_config.current.object_id
    }

    # 3. Matrix assignment (Single scope, multiple roles, single principal)
    "rg-matrix" = {
      scope = azurerm_resource_group.this.id
      role_definition_name = [
        "Key Vault Secrets Officer",
        "Storage Blob Data Contributor"
      ]
      principal_id = data.azurerm_client_config.current.object_id
    }
  }
}

output "assignments" {
  description = "The generated role assignments"
  value       = module.role_assignments.assignments
}
