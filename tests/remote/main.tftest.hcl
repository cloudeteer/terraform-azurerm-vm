provider "azurerm" {
  features {}
}

variables {
  name                = "vm-tftest-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-tftest-dev-we-01"
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
    image         = "Win2022Datacenter"
    computer_name = "tftest"

    backup_policy_id = run.setup_tests.backup_policy_id
    key_vault_id     = run.setup_tests.key_vault_id
    subnet_id        = run.setup_tests.subnet_id
  }
}

run "deploy_module_linux" {
  command = apply

  variables {
    image = "Ubuntu2204"

    backup_policy_id = run.setup_tests.backup_policy_id
    key_vault_id     = run.setup_tests.key_vault_id
    subnet_id        = run.setup_tests.subnet_id
  }
}
