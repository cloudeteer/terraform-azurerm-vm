provider "azurerm" {
  features {}
}

run "setup_tests" {
  command = apply

  module {
    source = "./tests/remote"
  }
}

run "deploy_module_windows" {
  command = apply

  variables {
    name          = "vm-tftest-dev-we-01"
    computer_name = "tftest"
    image         = "Win2022Datacenter"

    backup_policy_id    = run.setup_tests.backup_policy_id
    key_vault_id        = run.setup_tests.key_vault_id
    location            = run.setup_tests.resource_group_location
    resource_group_name = run.setup_tests.resource_group_name
    subnet_id           = run.setup_tests.subnet_id
  }
}

run "deploy_module_linux" {
  command = apply

  variables {
    name  = "vm-tftest-dev-we-01"
    image = "Ubuntu2204"

    backup_policy_id    = run.setup_tests.backup_policy_id
    key_vault_id        = run.setup_tests.key_vault_id
    location            = run.setup_tests.resource_group_location
    resource_group_name = run.setup_tests.resource_group_name
    subnet_id           = run.setup_tests.subnet_id
  }
}
