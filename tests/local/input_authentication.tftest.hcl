mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "test_input_authentication_windows_default" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "test_input_authentication_windows_password" {
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

run "test_input_authentication_windows_password_explicit" {
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

run "test_input_authentication_windows_ssh" {
  command = plan

  variables {
    image               = "Win2022Datacenter"
    authentication_type = "SSH"
  }

  expect_failures = [var.authentication_type]
}

run "test_input_authentication_linux_default" {
  command = plan

  variables {
    image            = "Ubuntu2204"
    operating_system = "Linux"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "test_input_authentication_linux_password" {
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
}

run "test_input_authentication_linux_password_explicit" {
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
}

run "test_input_authentication_linux_ssh" {
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
}

run "test_input_authentication_linux_ssh_explicit" {
  command = plan

  variables {
    admin_ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwVwmmz4jNNg5oQYVjpaer8R86TgyI3Ge+NqdFksjAHFO5ZK/Ds2PQb06jXeH/OS2iNBQEBcGiAob6Vx15mJd0iByGcmsHmFkTJeZND84JQ3oUT7jZwoF6Rofe1bW2N6tVRINJYB1qGFLSu1vx4jd4OuWQRh3tzmWy686WCy4XEaVNqYXPVocvHU7XM27wMPOvsAV+JlRXmfSYKvAqH/wCV7FzPsWq7cu7zGH2nuvFWGwtJt+Q5Nxh6V6C/5j4ZF/5/q9tBzpR39uPPtzGEBc5572G7BX0Rl5RbfvLBRTTI54K7DwujJ5l9E24VThqIRh/WqHTvfHJ85sQudRrS0V/ example"
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
}
