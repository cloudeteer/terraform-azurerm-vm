mock_provider "azurerm" {
  source = "./tests/examples/mock_datasources"
}

run "run_example_usage" {
  module {
    source = "./examples/usage"
  }
}
