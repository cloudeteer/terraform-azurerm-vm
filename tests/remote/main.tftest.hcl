provider "azurerm" {
  features {}
}

run "remote" {
  command = apply

  module {
    source = "./tests/remote"
  }
}
