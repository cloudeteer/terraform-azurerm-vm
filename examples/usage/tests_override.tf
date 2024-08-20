# This override file is mandatory for Terraform tests.
# Not needed to use this example.

terraform {
  required_providers {
    azapi   = { source = "azure/azapi" }
    azurerm = { source = "hashicorp/azurerm" }
    random  = { source = "hashicorp/random" }
    tls     = { source = "hashicorp/tls" }
  }
}

module "example" { source = "../.." }
