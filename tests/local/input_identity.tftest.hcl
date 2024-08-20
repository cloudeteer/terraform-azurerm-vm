mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "should_not_create_identity" {
  command = plan

  assert {
    condition     = local.create_identity == false && output.user_assigned_identity == null && output.system_assigned_identity == null
    error_message = "Expected that no identity would be created."
  }
}

run "should_identity_type_create_user_assigned_identity" {
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

run "should_identity_type_create_system_assigned_identity" {
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

run "should_identity_type_create_user_and_system_assigned_identity" {
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
