mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  name          = null
  computer_name = null
}

run "windows_computer_name_should_be_at_most_15_chars" {
  command = plan

  variables {
    name = "a-resource-name-that-is-longer-then-15-chars"
  }

  expect_failures = [var.computer_name]
}


run "use_short_windows_computer_name" {
  command = plan

  variables {
    name          = "a-resource-name-that-is-longer-then-15-chars"
    computer_name = "a-short-name"
  }
}
