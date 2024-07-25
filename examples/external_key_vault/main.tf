provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "key_vault"
  features {}
}

variable "backup_policy_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

module "example" {
  source = "../.."

  name                = "vm-example-dev-we-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  image            = "Win2022Datacenter"
  backup_policy_id = var.backup_policy_id
  subnet_id        = var.subnet_id

  # Disable store in Azure Key Vault by the module
  store_secret_in_key_vault = false
}

# Store the password by yourself in a Key Vault on a different provider
resource "azurerm_key_vault_secret" "example" {
  provider = azurerm.key_vault

  name         = "vm-example-dev-we-01-azureadmin-password"
  content_type = "Password"
  key_vault_id = var.key_vault_id

  # Get the secret value from the module output
  value = module.example.admin_password
}
