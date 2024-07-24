terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
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
