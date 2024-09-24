mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  image = true

  # Set default for this test file
  hotpatching_enabled = true
}

run "should_use_hotpatching_enabled_on_windows" {
  command = plan

  variables {
    image = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-hotpatch:latest"
  }
}

run "hotpatching_enabled_should_fail_on_linux" {
  command = plan

  variables {
    image = "Ubuntu2204"
  }

  expect_failures = [var.hotpatching_enabled]
}