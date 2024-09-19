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