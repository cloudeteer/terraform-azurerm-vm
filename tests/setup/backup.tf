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
