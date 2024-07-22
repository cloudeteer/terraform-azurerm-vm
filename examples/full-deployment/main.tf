#
# Virtual Machine
#

module "test" {
  source              = "cloudeteer/vm/azurerm"
  name                = "vm-example-dev-we-02"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  image        = "Ubuntu2204"
  key_vault_id = azurerm_key_vault.test.id
  subnet_id    = azurerm_subnet.test.id

  enable_backup_protected_vm = true
  backup_policy_id           = azurerm_backup_policy_vm.test.id

  identity = {
    type = "SystemAssigned"
  }
}

#
# Virtual Machine Resouce Group
#

resource "azurerm_resource_group" "test" {
  name     = "rg-test-dev-we-01"
  location = "West Europe"
}

#
# Virtual Machine Network
#

resource "azurerm_virtual_network" "test" {
  name                = "vnet-test-dev-we-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-test-dev-we-01"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

#
# Virtual Machine Credentials
#

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                     = "kv-test-dev-we-01"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  }
}

#
# Virtual Machine Backup
#

resource "azurerm_recovery_services_vault" "test" {
  name                = "rsv-test-dev-we-01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm" "test" {
  name                = "bkpvm-test-dev-we-01"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}
