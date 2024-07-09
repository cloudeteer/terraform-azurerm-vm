# terraform-azurerm-vm

[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)](CHANGELOG.md)
[![Keep a Changelog](https://img.shields.io/badge/changelog-Keep%20a%20Changelog%20v1.0.0-%23E05735)](CHANGELOG.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](.github/CONTRIBUTION.md)

This module is designed to simplify the deployment and management of virtual machines (VMs) in Microsoft Azure. This module provides a flexible and reusable way to create both Linux and Windows VMs, allowing users to specify various configuration parameters such as the VM size, operating system image, network interfaces, and resource group. The module supports both Linux and Windows operating systems and integrates seamlessly with other Azure resources such as virtual networks, subnets, and network interfaces.

<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
provider "azurerm" {
  features {}
}

module "example" {
  # source              = "cloudeteer/vm/azurerm"
  source              = "../.."
  name                = "vm-example-dev-gwc-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  image                 = "Win2022Datacenter"
  network_interface_ids = [azurerm_virtual_network.example.id]
}

resource "azurerm_resource_group" "example" {
  name     = "rg-example-dev-we-01"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-we-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-example-dev-we-01"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "nic-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.111.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| image | The name of the operating system image as a URN alias, URN. Valid URN format: `Publisher:Offer:Sku:Version` | `string` | n/a | yes |
| location | The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| name | The name of the Virtual Machine. Changing this forces a new resource to be created. | `string` | n/a | yes |
| network\_interface\_ids | A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine. | `list(string)` | n/a | yes |
| operating\_system | The operating system of the virtual machine to provision. Valid values are `Linux` or `Windows`. The default determines the operating system that will be used on the virtual machine image. | `string` | `null` | no |
| resource\_group\_name | The name of the Resource Group in which the Virtual Machine should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| size | The SKU which should be used for this Virtual Machine, such as `Standard_DS1_v2`. | `string` | `"Standard_DS1_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| image | n/a |
<!-- END_TF_DOCS -->
