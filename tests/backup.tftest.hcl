provider "azurerm" {
  features {}
}

variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  admin_password = "Pa$$w0rd"
  image          = "Ubuntu2204"
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.Network/virtualNetworks/vnet-example-dev-we-01/subnets/snet-01"
}

run "test_input_backup" {
  command = plan

  variables {
    backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.RecoveryServices/vaults/rsv-example-dev-we-01/backupPolicies/policy"
  }
}
