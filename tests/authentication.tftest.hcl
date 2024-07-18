mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
    }
  }
}

mock_provider "random" {}
mock_provider "tls" {}



variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  backup_policy_id = null
  subnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
}

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
    image               = "Win2022Datacenter"
    authentication_type = "Password"
    admin_password      = "@sdfqw3r7y"
    key_vault_id        = null
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
    image = "Ubuntu2204"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "test_input_authentication_linux_password" {
  command = plan

  variables {
    image               = "Ubuntu2204"
    authentication_type = "Password"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Password not created."
  }
}

run "test_input_authentication_linux_password_explicit" {
  command = plan

  variables {
    image               = "Ubuntu2204"
    authentication_type = "Password"
    admin_password      = "@sdfqw3r7y"
    key_vault_id        = null
  }

  assert {
    condition     = output.admin_password == var.admin_password
    error_message = "Password does not match."
  }
}

run "test_input_authentication_linux_ssh" {
  command = plan

  variables {
    image               = "Ubuntu2204"
    authentication_type = "SSH"
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
    image                = "Ubuntu2204"
    authentication_type  = "SSH"
    admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwVwmmz4jNNg5oQYVjpaer8R86TgyI3Ge+NqdFksjAHFO5ZK/Ds2PQb06jXeH/OS2iNBQEBcGiAob6Vx15mJd0iByGcmsHmFkTJeZND84JQ3oUT7jZwoF6Rofe1bW2N6tVRINJYB1qGFLSu1vx4jd4OuWQRh3tzmWy686WCy4XEaVNqYXPVocvHU7XM27wMPOvsAV+JlRXmfSYKvAqH/wCV7FzPsWq7cu7zGH2nuvFWGwtJt+Q5Nxh6V6C/5j4ZF/5/q9tBzpR39uPPtzGEBc5572G7BX0Rl5RbfvLBRTTI54K7DwujJ5l9E24VThqIRh/WqHTvfHJ85sQudRrS0V/ example"
    key_vault_id         = null
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
