mock_provider "azurerm" {}

variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  admin_password             = "Pa$$w0rd"
  image                      = "Ubuntu2204"
  subnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  enable_backup_protected_vm = false
}

run "test_identity_none" {
  command = plan

  assert {
    condition     = local.create_identity == false && length(output.identity) == 0
    error_message = "Expected that no identity would be created."
  }
}

run "test_identity_user_assigned" {
  command = plan

  variables {
    identity = {
      type = "UserAssigned"
    }
  }

  assert {
    condition     = local.create_identity == true && length(local.virtual_machine.identity) == 1
    error_message = "Expected an identity to be created, but none were provided."
  }
}

run "test_identity_system_assigned" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned"
    }
  }

  assert {
    condition     = local.create_identity == false && length(local.virtual_machine.identity) == 1
    error_message = "“Expected an identity block to be configured on the virtual machine, without the creation of a new identity."
  }
}

run "test_identity_user_and_system_assigned" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned, UserAssigned"
    }
  }

  assert {
    condition     = length(local.virtual_machine.identity) == 1 && local.virtual_machine.identity[0].type == "SystemAssigned, UserAssigned"
    error_message = "Expected the creation of an identity, with an identity block configured on the virtual machine."
  }
}
