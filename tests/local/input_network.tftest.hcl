mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  subnet_id = null
}

run "should_use_subnet_id" {
  command = plan

  variables {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  }

  assert {
    condition     = azurerm_network_interface.this[0].ip_configuration[0].subnet_id == var.subnet_id
    error_message = "Expected to create network interface and use subnet id vom variable input"
  }
}

run "should_fail_with_no_subnet_id" {
  command = plan

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.subnet_id,
  ]
}

run "should_use_network_interface_ids_from_input_only" {
  command = plan

  variables {
    create_network_interface = false
    network_interface_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic2"
    ]
  }

  assert {
    condition     = length(azurerm_network_interface.this) == 0
    error_message = "Expected to not create a network interface"
  }

  assert {
    condition     = length(local.virtual_machine.network_interface_ids) == 2
    error_message = "Expected two network interface IDs on virtual machine"
  }
}


run "should_assert_three_network_interfaces" {
  command = plan

  variables {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"

    network_interface_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic2"
    ]
  }

  assert {
    condition     = length(azurerm_network_interface.this) == 1
    error_message = "Expected to not create a network interface"
  }

  assert {
    condition     = length(local.virtual_machine.network_interface_ids) == 3
    error_message = "Expected three network interface IDs on virtual machine"
  }
}

run "should_create_public_ip_address" {
  command = plan

  variables {
    create_public_ip_address = true
    subnet_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 1
    error_message = "Expected to not create a public ip"
  }
}
