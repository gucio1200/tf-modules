terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Dummy resources to simulate an actual environment
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-identity-example"
  location = "East US"
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "uai-default-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_user_assigned_identity" "app1" {
  name                = "uai-app1-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Example Usage of the identity_role_manager Wrapper Module
module "identity_and_roles" {
  source = "../../"

  # 1. Define global defaults so you don't repeat yourself across all workloads
  default_principal_id              = azurerm_user_assigned_identity.default.principal_id
  default_user_assigned_identity_id = azurerm_user_assigned_identity.default.id
  default_issuer                    = "https://eastus.oic.prod-aks.azure.com/..." # Example AKS Issuer

  # 2. Turn on the workloads and provide scopes and overrides as needed
  workload_configs = {

    # Example 1: Standard workload. We pass the exact scope where its roles should be applied.
    # It will automatically inherit the "Reader" and "AcrPull" roles from workloads.tf.
    # We override the identity specifically for this app.
    "app-workload-1" = {
      scope                            = azurerm_resource_group.example.id
      principal_id                     = azurerm_user_assigned_identity.app1.principal_id
      custom_user_assigned_identity_id = azurerm_user_assigned_identity.app1.id
    }

    # Example 2: A workload that only has federated identity credentials predefined.
    # It doesn't have any roles defined in workloads.tf, so we don't even need to pass a scope!
    # It will fall back to using the global 'default_user_assigned_identity_id'.
    "app-workload-only-fic" = {}

    # Example 3: Workload with its base scope, plus an additional one-off role injected dynamically.
    "app-workload-custom-roles" = {
      scope = data.azurerm_client_config.current.subscription_id # Apply base roles to the whole subscription

      # We inject an extra one-off role targeting a completely different scope
      additional_role_assignments = [
        {
          scope                = "${azurerm_resource_group.example.id}/providers/Microsoft.KeyVault/vaults/my-vault"
          role_definition_name = "Key Vault Secrets User"
        }
      ]
    }

    # Note: If a key is missing (e.g., "some-future-workload"), it remains disabled and is ignored.
  }
}
