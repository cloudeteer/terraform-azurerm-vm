mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  image    = null
  timezone = "UTC"
}

run "test_input_timezone_windows" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }
}


run "test_input_timezone_linux" {
  command = plan

  variables {
    image = "Ubuntu2204"
  }

  expect_failures = [var.timezone]
}
