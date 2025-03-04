mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "entra_id_extension_and_identity_type_should_be_created" {
  command = plan

  variables {
    extensions = []
    entra_id_login = {
      enabled       = true
      principal_ids = ["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000001"]
    }

  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.entra_id_login) == 1
    error_message = "It is not possible to install the AAD-Extension without a given 'principal_id'."
  }

  assert {
    condition     = length(azurerm_role_assignment.entra_id_login) != 0
    error_message = "It is not possible to install the AAD-Extension without a given 'principal_id'."
  }

  assert {
    condition     = local.identity_type == "SystemAssigned"
    error_message = "It is not possible to install the EntraID-Extension without setting the Idenity to 'SystemAssigned' OR 'SystemAssigned, UserAssigned'."
  }

}

run "entra_id_extension_and_add_identity_type_should_be_created" {
  command = plan

  variables {
    extensions = []
    identity = {
    type = "UserAssigned" }
    entra_id_login = {
      enabled       = true
      principal_ids = ["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000001"]
    }

  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.entra_id_login) == 1
    error_message = "It is not possible to install the AAD-Extension without a given 'principal_id'."
  }

  assert {
    condition     = length(azurerm_role_assignment.entra_id_login) != 0
    error_message = "It is not possible to install the AAD-Extension without a given 'principal_id'."
  }

  assert {
    condition     = local.identity_type == "SystemAssigned, UserAssigned"
    error_message = "It is not possible to install the EntraID-Extension without setting the Idenity to 'SystemAssigned' OR 'SystemAssigned, UserAssigned'."
  }

}

run "nothing_should_be_created_regarding_entra_id_login" {
  command = plan

  variables {
    extensions = []
  }

  assert {
    condition     = length(azurerm_role_assignment.entra_id_login) == 0
    error_message = "No role_assignment for EntraID should be created when 'entra_id_login' is disabled."
  }

  assert {
    condition     = local.identity_type == var.identity
    error_message = "No identity type should be created when 'entra_id_login' is disabled."
  }

}
