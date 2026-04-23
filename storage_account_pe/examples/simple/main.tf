provider "azurerm" {
  features {}
}

locals {
  name     = "ex-pe-simple"
  location = "westeurope"
  tags = {
    Example    = local.name
    GithubRepo = "terraform-azurerm-storage-pe"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "sa1" {
  name                     = "saexpesimple1"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_account" "sa2" {
  name                     = "saexpesimple2"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "vnet-link-blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "vnet-link-file"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

################################################################################
# Storage Account Private Endpoint Module
################################################################################

module "storage_pe" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.this.id
  tags                = local.tags

  private_dns_zone_ids = {
    blob = [azurerm_private_dns_zone.blob.id]
    file = [azurerm_private_dns_zone.file.id]
  }

  storage_accounts = [
    {
      id                = azurerm_storage_account.sa1.id
      subresource_names = ["blob", "file"]
    },
    {
      id                = azurerm_storage_account.sa2.id
      subresource_names = ["blob"]
      tags              = { Environment = "Dev" }
    }
  ]
}
