mock_provider "azurerm" {}
mock_provider "random" {}
mock_provider "tls" {}

run "test_input_backup" {
  command = plan

  variables {
    backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.RecoveryServices/vaults/rsv-example-dev-we-01/backupPolicies/policy"
  }
}
