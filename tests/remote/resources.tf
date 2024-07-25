terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

resource "azurerm_resource_group" "tftest" {
  name     = var.resource_group_name
  location = var.location
}

#
# Backup
#

resource "azurerm_recovery_services_vault" "tftest" {
  name                = "rsv-tftest-dev-we-01"
  location            = azurerm_resource_group.tftest.location
  resource_group_name = azurerm_resource_group.tftest.name

  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "GeoRedundant"
}

resource "azurerm_backup_policy_vm" "tftest" {
  name                = "bkpvm-tftest-dev-we-01"
  resource_group_name = azurerm_resource_group.tftest.name

  recovery_vault_name = azurerm_recovery_services_vault.tftest.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

output "backup_policy_id" {
  value = azurerm_backup_policy_vm.tftest.id
}

#
# Key Vault
#

data "azurerm_client_config" "current" {}

resource "random_string" "tftest" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_key_vault" "tftest" {
  name                = "kv-tftest-dev-we-01-${random_string.tftest.result}"
  location            = azurerm_resource_group.tftest.location
  resource_group_name = azurerm_resource_group.tftest.name

  purge_protection_enabled = false
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
  }
}

output "key_vault_id" {
  value = azurerm_key_vault.tftest.id
}


#
# Network
#

resource "azurerm_virtual_network" "tftest" {
  name                = "vnet-tftest-dev-we-01"
  location            = azurerm_resource_group.tftest.location
  resource_group_name = azurerm_resource_group.tftest.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tftest" {
  name                = "snet-tftest-dev-we-01"
  resource_group_name = azurerm_resource_group.tftest.name

  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.tftest.name
}

output "subnet_id" {
  value = azurerm_subnet.tftest.id
}
