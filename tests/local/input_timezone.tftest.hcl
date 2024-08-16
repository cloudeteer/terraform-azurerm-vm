mock_provider "azurerm" {}
mock_provider "random" {}
mock_provider "tls" {}

mock_provider "azapi" {
  source = "tests/local/mock_datasources"
}

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
