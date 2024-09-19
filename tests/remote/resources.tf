terraform {
  required_version = "~> 1.9"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14"
    }

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
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#
# Resource Group
#

resource "random_string" "rg_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tftest" {
  name     = "rg-tftest-dev-euw-${random_string.rg_suffix.result}"
  location = "westeurope"
}

output "resource_group_name" {
  value = azurerm_resource_group.tftest.name
}

output "resource_group_location" {
  value = azurerm_resource_group.tftest.location
}

#
# Backup
#

data "azurerm_resources" "recovery_services_vault" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.RecoveryServices/vaults"

  required_tags = {
    service = "terraform-module-tests"
  }
}

output "backup_policy_id" {
  value = "${one(data.azurerm_resources.recovery_services_vault.resources[*].id)}/backupPolicies/EnhancedPolicy"
}

#
# Key Vault
#

data "azurerm_resources" "key_vault" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.KeyVault/vaults"

  required_tags = {
    service = "terraform-module-tests"
  }
}

output "key_vault_id" {
  value = one(data.azurerm_resources.key_vault.resources[*].id)
}

#
# Network
#

data "azurerm_resources" "virtual_network" {
  resource_group_name = "rg-tfmodtest-prd-euw-01"

  type = "Microsoft.Network/virtualNetworks"

  required_tags = {
    service = "terraform-module-tests"
  }
}

output "subnet_id" {
  value = "${one(data.azurerm_resources.virtual_network.resources[*].id)}/subnets/DefaultSubnet"
}
