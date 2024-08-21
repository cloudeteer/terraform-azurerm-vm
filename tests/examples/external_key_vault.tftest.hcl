mock_provider "azapi" { source = "./tests/examples/mocks" }
mock_provider "azurerm" { source = "./tests/examples/mocks" }
mock_provider "random" { source = "./tests/examples/mocks" }
mock_provider "tls" { source = "./tests/examples/mocks" }

mock_provider "azurerm" {
  alias  = "key_vault"
  source = "./tests/examples/mocks"
}

variables {
  location            = "West Europe"
  name                = "vm-tftest-dev-we-01"
  resource_group_name = "rg-tftest-dev-we-01"

  subnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
  backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.RecoveryServices/vaults/rsv-example-dev-we-01/backupPolicies/policy"
}

run "test_example_external_key_vault" {
  command = apply

  module {
    source = "./examples/external_key_vault"
  }
}
