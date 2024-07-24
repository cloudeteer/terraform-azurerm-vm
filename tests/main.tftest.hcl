provider "azurerm" {
  features {}
}

variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  admin_password             = "Pa$$w0rd"
  enable_backup_protected_vm = false
  image                      = "Ubuntu2204"
  store_secret_in_key_vault  = false
  subnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
}

run "test_main" {
  command = plan
}
