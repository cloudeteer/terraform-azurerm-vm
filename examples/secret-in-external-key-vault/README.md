# Example: secret-in-external-key-vault

In some cases, the Azure Key Vault intended to store the generated secrets from Terraform is located in a different subscription than the virtual machine being deployed by the module. In such scenarios, an additional Terraform AzureRM provider is required for the `azurerm_key_vault_secret` resource, which is not supported by this module.

To handle this, disable the storage of the secret within the module and manage the secret storage yourself using an `azurerm_key_vault_secret` resource. Reference the output from the module as needed.
