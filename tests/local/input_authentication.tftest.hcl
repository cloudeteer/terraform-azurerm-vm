mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "should_create_password_with_defaults_on_windows" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "should_authentication_type_create_password_on_windows" {

  command = plan

  variables {
    image               = "Win2022Datacenter"
    authentication_type = "Password"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "should_input_admin_password_output_same_value_on_windows" {
  command = plan

  variables {
    admin_password            = bcrypt(uuid())
    authentication_type       = "Password"
    image                     = "Win2022Datacenter"
    store_secret_in_key_vault = false
  }

  assert {
    condition     = output.admin_password == var.admin_password
    error_message = "Password does not match."
  }
}

run "should_not_allow_authentication_type_ssh_on_windows" {
  command = plan

  variables {
    image               = "Win2022Datacenter"
    authentication_type = "SSH"
  }

  expect_failures = [var.authentication_type]
}

run "should_create_password_with_defaults_on_linux" {
  command = plan

  variables {
    image            = "Ubuntu2204"
    operating_system = "Linux"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == false
    error_message = "Expected password authentication to be enabled."
  }
}

run "should_authentication_type_create_password_on_linux" {
  command = plan

  variables {
    authentication_type = "Password"
    image               = "Ubuntu2204"
    operating_system    = "Linux"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == false
    error_message = "Expected password authentication to be enabled."
  }
}

run "should_input_admin_password_output_same_value_on_linux" {
  command = plan

  variables {
    admin_password            = bcrypt(uuid())
    authentication_type       = "Password"
    image                     = "Ubuntu2204"
    operating_system          = "Linux"
    store_secret_in_key_vault = false
  }

  assert {
    condition     = output.admin_password == var.admin_password
    error_message = "Password does not match."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == false
    error_message = "Expected password authentication to be enabled."
  }
}

run "should_authentication_type_ssh_create_key_and_store_in_key_vault_on_linux" {
  command = plan

  variables {
    authentication_type = "SSH"
    image               = "Ubuntu2204"
    operating_system    = "Linux"
  }

  assert {
    condition     = length(tls_private_key.this) == 1
    error_message = "SSH key not created."
  }

  assert {
    condition     = length(azurerm_key_vault_secret.this) == 1
    error_message = "Expected to have Key Vault secret with generated SSH private key."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == true
    error_message = "Expected password authentication to be disabled."
  }
}

run "should_input_admin_ssh_public_key_output_same_value_on_linux" {
  command = plan

  variables {
    admin_ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPAi7Yj75umWSxD0r73EZhbuIDJzD5bfBwRIJmrm8oj example"
    authentication_type       = "SSH"
    image                     = "Ubuntu2204"
    operating_system          = "Linux"
    store_secret_in_key_vault = false
  }

  assert {
    condition     = length(tls_private_key.this) == 0
    error_message = "SSH key created even if admin_ssh_public_key is set."
  }

  assert {
    condition     = output.admin_ssh_public_key == var.admin_ssh_public_key
    error_message = "SSH key does not match."
  }

  assert {
    condition     = length(azurerm_key_vault_secret.this) == 0
    error_message = "Expected to have no Key Vault secret because admin_ssh_public_key is set."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == true
    error_message = "Expected password authentication to be disabled."
  }
}

run "test_input_authentication_linux_password_ssh" {
  command = plan

  variables {
    authentication_type = "Password, SSH"
    image               = "Ubuntu2204"
    operating_system    = "Linux"
  }

  assert {
    condition     = length(tls_private_key.this) == 1
    error_message = "SSH key not created."
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }

  assert {
    condition     = length(azurerm_key_vault_secret.this) == 2
    error_message = "Expected to have Key Vault secret with generated password and SSH private key."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].disable_password_authentication == false
    error_message = "Expected password authentication to be enabled."
  }
}
