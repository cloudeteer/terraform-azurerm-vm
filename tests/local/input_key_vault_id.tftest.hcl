mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

run "should_not_add_key_vault_id_as_tag_to_virtual_machine" {
  command = plan

  variables {
    image                     = "Ubuntu2204"
    operating_system          = "Linux"
    store_secret_in_key_vault = false
    admin_password            = bcrypt(uuid())
    tags = {
      "var_tags" = "var_tag"
    }
    tags_virtual_machine = {
      "var_vm_tags" = "var_vm_tag"
    }
    key_vault_id = null
  }

  assert {
    condition     = contains(keys(azurerm_linux_virtual_machine.this[0].tags), "key_vault_id") == false
    error_message = "Tag key_vault_id should not exist on the virtual machine"
  }
}

run "should_add_key_vault_id_as_tag_to_virtual_machine" {
  command = plan

  variables {
    image            = "Ubuntu2204"
    operating_system = "Linux"
    key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/localvault"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].tags["key_vault_id"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/localvault"
    error_message = "Expected to add key vault id as tag to virtual machine"
  }
}
