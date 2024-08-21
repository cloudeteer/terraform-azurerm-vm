mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  image = null

  # Set default timezone for this test file
  timezone = "UTC"
}

run "should_use_timezone_on_windows" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }
}


run "timezone_should_fail_on_linux" {
  command = plan

  variables {
    image = "Ubuntu2204"
  }

  expect_failures = [var.timezone]
}
