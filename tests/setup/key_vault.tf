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
