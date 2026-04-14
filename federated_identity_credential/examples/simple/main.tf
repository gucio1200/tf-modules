provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  name     = "ex-${basename(path.cwd)}"
  location = "westeurope"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-azurerm-federated-identity-credential"
    GithubOrg  = "my-org"
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.name
  location = local.location
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "this" {
  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags
}

################################################################################
# Federated Identity Credential Module
################################################################################

module "federated_identity_credential" {
  source = "../../"

  default_issuer                    = "https://oidc.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/"
  default_user_assigned_identity_id = azurerm_user_assigned_identity.this.id

  credentials = {
    # Using defaults (issuer and user_assigned_identity_id from module defaults)
    minimal = {
      name      = "app-minimal"
      namespace = "default"
    }

    # Overriding all possible values
    custom = {
      name                      = "app-custom"
      namespace                 = "kube-system"
      issuer                    = "https://oidc.prod-aks.azure.com/11111111-1111-1111-1111-111111111111/11111111-1111-1111-1111-111111111111/"
      audience                  = "api://CustomAudience"
      user_assigned_identity_id = azurerm_user_assigned_identity.this.id
    }
  }
}
