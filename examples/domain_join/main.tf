resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev-we-01"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                = "snet-example-dev-we-01"
  resource_group_name = azurerm_resource_group.example.name

  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "rsv-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "GeoRedundant"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "bkpvm-example-dev-we-01"
  resource_group_name = azurerm_resource_group.example.name

  policy_type         = "V2"
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "kv-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  purge_protection_enabled = false
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  }
}

#
# Get domain join credentials from Azure Key Vault
#

data "azurerm_key_vault" "domain_join_credentials" {
  name                = "example"      # <--- CHANGE THIS VALUE
  resource_group_name = "rg-launchpad" # <--- CHANGE THIS VALUE
}

data "azurerm_key_vault_secret" "domain_join_password" {
  name         = "domain-join-password"
  key_vault_id = data.azurerm_key_vault.domain_join_credentials.id
}

data "azurerm_key_vault_secret" "domain_join_user" {
  name         = "domain-join-user"
  key_vault_id = data.azurerm_key_vault.domain_join_credentials.id
}


#trivy:ignore:avd-azu-0039
module "example" {
  source = "cloudeteer/vm/azurerm"

  name                = "vm-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  backup_policy_id = azurerm_backup_policy_vm.example.id
  computer_name    = "example"
  image            = "Win2022Datacenter"
  key_vault_id     = azurerm_key_vault.example.id
  subnet_id        = azurerm_subnet.example.id

  #
  # Enable domain join and provide the domain join parameters
  #

  domain_join = {
    enabled     = true
    domain_name = "example.com"
    ou_path     = "OU=Computers,DC=example,DC=com"
    join_user   = data.azurerm_key_vault_secret.domain_join_user.value
  }

  domain_join_password = data.azurerm_key_vault_secret.domain_join_password.value
}
