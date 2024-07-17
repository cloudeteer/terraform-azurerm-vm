provider "azurerm" {
  features {}
}

variables {
  location            = "West Europe"
  resource_group_name = "rg-test-dev-we-01"
}

run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "deploy_module_windows" {
  command = apply

  variables {
    backup_policy_id = null
    image            = "Win2022Datacenter"
    name             = "vm-example-dev-we-01"
    subnet_id        = run.setup_tests.subnet_id
  }
}

run "deploy_module_linux" {
  command = apply

  variables {
    backup_policy_id = null
    image            = "Ubuntu2204"
    name             = "vm-example-dev-we-02"
    subnet_id        = run.setup_tests.subnet_id
  }
}
