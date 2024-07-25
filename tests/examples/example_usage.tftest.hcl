mock_provider "azurerm" {
  source = "./tests/examples/mock_datasources"
}

run "test_example_usage" {
  module {
    source = "./examples/usage"
  }
}
