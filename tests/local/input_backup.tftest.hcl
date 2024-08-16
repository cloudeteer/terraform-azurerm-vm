mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  backup_policy_id = null
}

run "test_input_backup_default" {
  command = plan

  variables {
    enable_backup_protected_vm = true
  }

  expect_failures = [var.backup_policy_id]
}

run "test_input_backup_disabled" {
  command = plan

  variables {
    enable_backup_protected_vm = false
  }
}

run "test_input_backup_enabled" {
  command = plan

  variables {
    enable_backup_protected_vm = true
    backup_policy_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-dev-we-01/providers/Microsoft.RecoveryServices/vaults/rsv-example-dev-we-01/backupPolicies/policy"
  }
}
