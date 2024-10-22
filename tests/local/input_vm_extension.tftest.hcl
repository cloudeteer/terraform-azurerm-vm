mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "no_extension_should_be_created" {
  command = plan

  variables {
    allow_extension_operations = false
    extensions                 = []
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.this) == 0
    error_message = "It is not possible to install extension with 'allow_extension_operations = false'. The azurerm_virtual_machine_extension.this length is ${length(azurerm_virtual_machine_extension.this)}."
  }
}

run "no_extension_should_be_created_2" {
  command = plan

  variables {
    allow_extension_operations = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.this) == 0
    error_message = "It is not possible to install extension with 'allow_extension_operations = false'. The azurerm_virtual_machine_extension.this length is ${length(azurerm_virtual_machine_extension.this)}."
  }
}
