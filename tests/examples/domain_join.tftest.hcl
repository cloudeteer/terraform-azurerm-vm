mock_provider "azapi" { source = "./tests/examples/mocks" }
mock_provider "azurerm" { source = "./tests/examples/mocks" }
mock_provider "random" { source = "./tests/examples/mocks" }
mock_provider "tls" { source = "./tests/examples/mocks" }

run "test_example_usage" {
  command = apply

  module {
    source = "./examples/usage"
  }
}
