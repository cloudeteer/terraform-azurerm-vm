# terraform-azurerm-vm

[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)](CHANGELOG.md)
[![Keep a Changelog](https://img.shields.io/badge/changelog-Keep%20a%20Changelog%20v1.0.0-%23E05735)](CHANGELOG.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](.github/CONTRIBUTION.md)

This module is designed to simplify the deployment and management of virtual machines (VMs) in Microsoft Azure. This module provides a flexible and reusable way to create both Linux and Windows VMs, allowing users to specify various configuration parameters such as the VM size, operating system image, network interfaces, and resource group. The module supports both Linux and Windows operating systems and integrates seamlessly with other Azure resources such as virtual networks, subnets, and network interfaces.

<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
module "example" {
  source              = "cloudeteer/vm/azurerm"
  name                = "vm-example-dev-we-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  image     = "Win2022Datacenter"
  subnet_id = azurerm_subnet.example.id
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
```

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.111.0)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.0)

- <a name="provider_tls"></a> [tls](#provider\_tls) (~> 4.0)



## Resources

The following resources are used by this module:

- [azurerm_backup_protected_vm.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) (resource)
- [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) (resource)
- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id)

Description: The ID of the backup policy to use.

Type: `string`

### <a name="input_image"></a> [image](#input\_image)

Description: The URN or URN alias of the operating system image. Valid URN format is `Publisher:Offer:SKU:Version`. Use `az vm image list` to list possible URN values.

Valid URN aliases are:
- `CentOS85Gen2`
- `Debian11`
- `FlatcarLinuxFreeGen2`
- `OpenSuseLeap154Gen2`
- `RHELRaw8LVMGen2`
- `SuseSles15SP3`
- `Ubuntu2204`
- `Win2022Datacenter`
- `Win2022AzureEditionCore`
- `Win2019Datacenter`
- `Win2016Datacenter`
- `Win2012R2Datacenter`
- `Win2012Datacenter`
- `Win2008R2SP1`

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure location where the virtual machine should reside.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the virtual machine. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which the virtual machine should exist. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password)

Description: Password to use for the local administrator on this virtual machine. If not set, a password will be generated and stored in the Key Vault specified by key\_vault\_id.

Type: `string`

Default: `null`

### <a name="input_admin_ssh_public_key"></a> [admin\_ssh\_public\_key](#input\_admin\_ssh\_public\_key)

Description: Public key to use for SSH authentication. Must be at least 2048-bit and in ssh-rsa format.

Type: `string`

Default: `null`

### <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username)

Description: Username of the local administrator for the virtual machine.

Type: `string`

Default: `"azureadmin"`

### <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type)

Description: Specifies the authentication type to use. Valid options are `SSH` or `Password`. Windows virtual machines support only `Password`.

Type: `string`

Default: `"Password"`

### <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics)

Description: Enable boot diagnostics and optionally specify the storage account to use to store boot diagnostics. The default is to use a managed storage account to store boot diagnostics when enabled.

Optional parameters:

- `enable` - Whether to enable (`true`) or disable (`false`) boot diagnostics.
- `storage_account_uri` - The endpoint for the Azure storage account that should be used to store boot diagnostics, including console output and hypervisor screenshots.

Type:

```hcl
object({
    enable              = optional(bool, true)
    storage_account_uri = optional(string)
  })
```

Default:

```json
{
  "enable": true
}
```

### <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name)

Description: Specifies the hostname to use for this virtual machine. If unspecified, it defaults to the first subscrings up to the `-` char without the `vm-` prefix of `name`. If this value is not a valid hostname, you must specify a hostname.

Example: If `name` is `vm-example-prd-gwc-01`, `computer_name` will be `example`.

Type: `string`

Default: `null`

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: Key Vault ID to store the generated admin password or admin SSH private key. Required when admin\_password or admin\_ssh\_public\_key is not set. Must not be set if either admin\_password or admin\_ssh\_public\_key is set.

Type: `string`

Default: `null`

### <a name="input_network_interface_ids"></a> [network\_interface\_ids](#input\_network\_interface\_ids)

Description: A list of network interface IDs to attach to this virtual machine. The first network interface ID in this list will be the primary network interface of the virtual machine. If `subnet_id` is set, then the network interface created by this module will be the primary network interface of the virtual machine.

Type: `list(string)`

Default: `null`

### <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system)

Description: The virtual machine's operating system. Valid values are `Linux` or `Windows`. The default is `null`, which determines the operating system to use based on the virtual machine image offering.

Type: `string`

Default: `null`

### <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk)

Description: Operating system disk parameters.

Optional parameters:
- `caching` - The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
- `disk_encryption_set_id` - The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`.
  - **NOTE**: The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault.
- `disk_size_gb` - The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
  - **NOTE**: If specified this must be equal to or larger than the size of the Image the Virtual Machine is based on. When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space.
- `name` - The name which should be used for the Internal OS Disk. Default is `name` prefixed with `osdisk-`.
- `security_encryption_type` - Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`.
  - **NOTE**: `vtpm_enabled` must be set to true when `security_encryption_type` is specified.
  - **NOTE**: `encryption_at_host_enabled` cannot be set to true when `security_encryption_type` is set to `DiskWithVMGuestState`.
- `secure_vm_disk_encryption_set_id` - The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`.
  - **NOTE**: `secure_vm_disk_encryption_set_id` can only be specified `when security_encryption_type` is set to `DiskWithVMGuestState`.
- `storage_account_type` - The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`.
- `write_accelerator_enabled` - Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`.
  - **NOTE**: This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`.

Type:

```hcl
object({
    caching                          = optional(string, "ReadWrite")
    disk_size_gb                     = optional(string)
    name                             = optional(string)
    storage_account_type             = optional(string, "Premium_LRS")
    disk_encryption_set_id           = optional(string)
    write_accelerator_enabled        = optional(bool, false)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
  })
```

Default:

```json
{
  "caching": "ReadWrite",
  "storage_account_type": "Premium_LRS",
  "write_accelerator_enabled": false
}
```

### <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address)

Description: The static IP address to use. If not set (default), a dynamic IP address is assigned.

Type: `string`

Default: `null`

### <a name="input_size"></a> [size](#input\_size)

Description: The [SKU](https://cloudprice.net/) to use for this virtual machine.

Common sizes:
- `Standard_B2s`
- `Standard_B2ms`
- `Standard_D2s_v5`
- `Standard_D4s_v5`
- `Standard_DC2s_v2`
- `Standard_DS1_v2`
- `Standard_DS2_v2`
- `Standard_E4s_v5`
- `Standard_E4bds_v5`
- `Standard_F2s_v2`
- `Standard_F4s_v2`

Type: `string`

Default: `"Standard_DS1_v2"`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet where the virtual machine's primary network interface should be located.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password)

Description: n/a

### <a name="output_admin_ssh_private_key"></a> [admin\_ssh\_private\_key](#output\_admin\_ssh\_private\_key)

Description: n/a

### <a name="output_admin_ssh_public_key"></a> [admin\_ssh\_public\_key](#output\_admin\_ssh\_public\_key)

Description: n/a

### <a name="output_image"></a> [image](#output\_image)

Description: n/a

### <a name="output_key_vault_secret_id"></a> [key\_vault\_secret\_id](#output\_key\_vault\_secret\_id)

Description: n/a
<!-- END_TF_DOCS -->
