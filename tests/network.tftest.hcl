provider "azurerm" {
  features {}
}

variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  admin_password             = "Pa$$w0rd"
  enable_backup_protected_vm = false
  image                      = "Ubuntu2204"
}

run "test_input_subnet_id" {
  command = plan

  variables {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  }
}

run "test_input_subnet_id_empty" {
  command = plan

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.subnet_id,
  ]
}

run "test_input_interface_ids" {
  command = plan

  variables {
    create_network_interface = false
    network_interface_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic2"
    ]
  }
}

run "test_input_subnet_id_and_network_interface_ids_set" {
  command = plan

  variables {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"

    network_interface_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic2"
    ]
  }
}
