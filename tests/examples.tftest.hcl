mock_provider "azurerm" {

  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
      object_id = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/SNET-MOCK"
    }
  }

  mock_resource "azurerm_backup_policy_vm" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.RecoveryServices/vaults/RSV-MOCK/backupPolicies/MOCK"
    }
  }

  mock_resource "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.KeyVault/vaults/KV-MOCK"
    }
  }

  mock_resource "azurerm_network_interface" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.Network/networkInterfaces/NIC-MOCK"
    }
  }

  mock_resource "azurerm_linux_virtual_machine" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.Compute/virtualMachines/VM-MOCK"
    }
  }

  mock_resource "azurerm_windows_virtual_machine" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-MOCK/providers/Microsoft.Compute/virtualMachines/VM-MOCK"
    }
  }
}

run "run_example_usage" {
  module {
    source = "./examples/usage"
  }
}
