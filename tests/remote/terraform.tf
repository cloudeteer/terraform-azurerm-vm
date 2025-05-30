terraform {
  required_version = "1.9.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "2.0.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.0"
    }
  }
}
