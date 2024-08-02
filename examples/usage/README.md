# Example: Usage

This primary usage example is also included in the [README.md](../../README.md) of this module. It demonstrates the virtual machine module using as many default values as possible.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- An [Azure account](https://azure.microsoft.com/en-us/free/) with the appropriate permissions.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated.

## Steps to Deploy

1. **Initialize the Terraform Configuration**

   Initialize the Terraform configuration to download the necessary providers and modules.

   ```shell
   terraform init
   ```

2. **Apply the Terraform Configuration**

   Apply the configuration to create the resources defined in your Terraform files.

   ```shell
   terraform apply
   ```

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Configuration Language](https://www.terraform.io/docs/language/index.html)
- [Azure Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
