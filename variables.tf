locals {
  windows_license_types = ["None", "Windows_Client", "Windows_Server"]
  linux_license_types = [
    "RHEL_BYOS", "RHEL_BASE", "RHEL_EUS", "RHEL_SAPAPPS", "RHEL_SAPHA", "RHEL_BASESAPAPPS", "RHEL_BASESAPHA",
    "SLES_BYOS", "SLES_SAP", "SLES_HPC"
  ]

  identity_type = (
    var.entra_id_login.enabled ? (
      try(var.identity.type, "") == "UserAssigned" ?
      replace(var.identity.type, "UserAssigned", "SystemAssigned, UserAssigned") :
      "SystemAssigned"
    ) :
  try(var.identity.type, null))
}

variable "additional_capabilities" {
  description = <<-EOT
  Enable additional capabilities.

  Optional arguments:

  Argument | Description
  -- | --
  `ultra_ssd_enabled` | Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine?
  `hibernation_enabled` | Whether to enable the hibernation capability or not.
  EOT

  type = object({
    ultra_ssd_enabled   = optional(bool)
    hibernation_enabled = optional(bool)
  })

  default = null
}

variable "additional_unattend_content" {
  description = <<-EOT
    Additional content for the unattend.xml file used during Windows installation. This feature is not supported on Linux Virtual Machines.

    Required arguments:

    Argument | Description
    -- | --
    `content` | The XML formatted content that is added to the unattend.xml file for the specified path and component.
    `setting` | The name of the setting to which the content applies. Possible values are `AutoLogon` and `FirstLogonCommands`.
  EOT

  type = object({
    content = string
    setting = string
  })

  default = null

  validation {
    condition     = var.additional_unattend_content == null ? true : local.is_windows
    error_message = "Additional unanttend content can only be defined for Windows virtual machines."
  }
}

variable "admin_password" {
  description = "Password to use for the local administrator on this virtual machine. If not set, a password will be generated and stored in the Key Vault specified by key_vault_id."
  default     = null
  type        = string
}

variable "admin_ssh_key_algorithm" {
  description = "Algorithm for the admin SSH key pair, used only if `authentication_type` is `SSH` and no `admin_ssh_public_key` is provided. Valid values: `RSA`, `ED25519`."
  default     = "ED25519"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Public key to use for SSH authentication. Must be at least 2048-bit and in ssh-rsa or ssh-ed25519 format."
  default     = null
  type        = string
}

variable "admin_username" {
  default     = "azureadmin"
  description = "Username of the local administrator for the virtual machine."
  type        = string
}

variable "allow_extension_operations" {
  description = "Should Extension Operations be allowed on this Virtual Machine?"
  type        = bool
  default     = true
}

variable "architecture" {
  description = "The virtual machine's architecture. Valid values are `x86` or `arm`. The default is `null`, which determines the architecture to use based on the virtual machine image offering."

  type    = string
  default = null

}

variable "authentication_type" {
  description = "Specifies the authentication type to use. Valid options are `Password`, `SSH`, or `Password, SSH`. Windows virtual machines support only `Password`."
  default     = "Password"
  type        = string

  validation {
    condition     = contains(["Password", "SSH", "Password, SSH"], var.authentication_type)
    error_message = "Valid values for authentication_type are `Password`, `SSH`, or `Password, SSH`."
  }

  validation {
    condition     = strcontains(var.authentication_type, "SSH") ? !local.is_windows : true
    error_message = "On Windows operating systems, authentication type \"SSH\" is not supported. Use authentication type \"Password\" for Windows images."
  }
}

variable "availability_set_id" {
  description = "Specifies the ID of the Availability Set in which the Virtual Machine should exist"

  type    = string
  default = null
}

variable "backup_policy_id" {
  description = "The ID of the backup policy to use."
  type        = string
  default     = null

  validation {
    condition     = (var.enable_backup_protected_vm && var.backup_policy_id != null) || !var.enable_backup_protected_vm
    error_message = "A backup policy ID is required when backup_protected_vm.enabled is true."
  }
}

variable "boot_diagnostics" {
  description = <<-EOT
    Enable boot diagnostics and optionally specify the storage account to use to store boot diagnostics. The default is to use a managed storage account to store boot diagnostics when enabled.

    Optional parameters:

    Parameter | Description
    -- | --
    `enable` | Whether to enable (`true`) or disable (`false`) boot diagnostics.
    `storage_account_uri` | The endpoint for the Azure storage account that should be used to store boot diagnostics, including console output and hypervisor screenshots.
  EOT

  type = object({
    enabled             = optional(bool, true)
    storage_account_uri = optional(string)
  })

  default = {
    enabled = true
  }
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  description = <<-EOT
    Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM.

    **NOTE**: Can only be set to true when `patch_mode` is set to `AutomaticByPlatform`.
  EOT

  type    = bool
  default = true
}

variable "computer_name" {
  description = <<-EOT
    Specifies the hostname to use for this virtual machine. If unspecified, it defaults to `name`.
  EOT

  type    = string
  default = null

  validation {
    condition     = local.is_windows && var.computer_name != null ? length(var.computer_name) <= 15 : true
    error_message = "Windows computer name can be at most 15 characters."
  }

  validation {
    condition     = local.is_windows && var.computer_name == null ? length(var.name) <= 15 : true
    error_message = "Windows computer name can be at most 15 characters. Variable \"computer_name\" is not set, falling back to \"name\" which is ${length(var.name)} chatacters long. Set \"computer_name\" explicitly."
  }
}

variable "create_network_interface" {
  description = "Create (`true`) a network interface for the virtual machine. If disabled (`false`), the `subnet_id` must be omitted and `network_interface_ids` must be defined."
  type        = bool
  default     = true
}

variable "create_public_ip_address" {
  description = "If set to `true` a Azure public IP address will be created and assigned to the default network interface."
  default     = false
  type        = bool
}

variable "custom_data" {
  description = "The Base64-Encoded Custom Data which should be used for this Virtual Machine."

  type    = string
  default = null
}

variable "data_disks" {
  description = <<-EOT
    Additional disks to be attached to the virtual machine.

    Required parameters:

    Parameter | Description
    -- | --
    `disk_size_gb` | Specifies the size of the managed disk to create in gigabytes.
    `lun` | The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine.

    Optional parameters:

    Parameter | Description
    -- | --
    `caching` | Specifies the caching requirements for this Data Disk. Possible values include `None`, `ReadOnly` and `ReadWrite`.
    `create_option` | The method to use when creating the managed disk. Possible values include: `Empty` - Create an empty managed disk. `Copy` - Copy an existing managed disk or snapshot (specified with `source_resource_id`).
    `name` | Specifies the name of the Managed Disk. If omitted a name will be generated based on `name`.
    `storage_account_type` | The type of storage to use for the managed disk. Possible values are `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `PremiumV2_LRS`, `Premium_ZRS`, `StandardSSD_LRS` or `UltraSSD_LRS`.
  EOT

  type = list(object({
    caching              = optional(string, "ReadWrite")
    create_option        = optional(string, "Empty")
    disk_size_gb         = number
    lun                  = number
    name                 = optional(string)
    storage_account_type = optional(string, "Premium_LRS")
    source_resource_id   = optional(string)
  }))

  default = []
}

variable "enable_automatic_updates" {
  description = "Specifies whether Automatic Updates are enabled for Windows Virtual Machines. This feature is not supported on Linux Virtual Machines."

  type    = bool
  default = true
}

variable "enable_backup_protected_vm" {
  description = "Enable (`true`) or disable (`false`) a backup protected VM."
  type        = bool
  default     = true
}

variable "encryption_at_host_enabled" {
  description = <<-EOT
    Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?

    **NOTE**: Requires `Microsoft.Compute/EncryptionAtHost` to be enabled at the subscription level.
  EOT

  type    = bool
  default = true
}

variable "entra_id_login" {
  description = <<-EOD
      Configures Entra ID-based login for virtual machines. Set `enabled` to `true` to activate this feature and define the list of `principal_ids` permitted to log in.
    **Note**: This feature requires at least 1GB of memory and is not supported on certain SKUs, including `Standard_B1ls`, `Basic_A0`, and `Standard_A0`.
  EOD
  type = object({
    enabled       = optional(bool)
    principal_ids = optional(list(string), [])
  })
  default = ({
    enabled = false
  })

  validation {
    condition = (!var.entra_id_login.enabled ? true :
    !contains(["Standard_B1ls", "Basic_A0", "Standard_A0"], var.size))
    error_message = "Entra ID Extension requires at least 1GB of memory; set var.size to an SKU that meets this requirement."
  }

  validation {
    condition     = !var.entra_id_login.enabled ? true : length(var.entra_id_login.principal_ids) > 0
    error_message = "When 'entra_id_login.enabled' is 'true', 'principal_ids' must contain at least one valid principal ID."
  }

}

variable "extensions" {
  description = <<-EOT
    List of extensions to enable.

    Possible values:
    - `NetworkWatcherAgent`
    - `AzureMonitorAgent`
    - `AzurePolicy`
    - `AntiMalware`

    **NOTE**: The extensions listed here will only be applied if `allow_extension_operations` is set to `true` (default). If `allow_extension_operations` is set to `false`, this list will be ignored and no extensions will be created.
  EOT

  type = list(string)

  default = [
    "NetworkWatcherAgent",
    "AzureMonitorAgent",
    "AzurePolicy",
    "AntiMalware",
  ]
}

variable "hotpatching_enabled" {

  description = <<-EOT
    Should the Windows VM be patched without requiring a reboot? [more infos](https://learn.microsoft.com/windows-server/get-started/hotpatch)

    **NOTE**: Hotpatching can only be enabled if the `patch_mode` is set to `AutomaticByPlatform`, the `provision_vm_agent` is set to `true`, your `source_image_reference` references a hotpatching enabled image, and the VM's `size` is set to a [Azure generation 2 VM](https://learn.microsoft.com/en-gb/azure/virtual-machines/generation-2#generation-2-vm-sizes).

    **CAUTION**: The setting `bypass_platform_safety_checks_on_user_schedule_enabled` is set to `true` by default. To enable hotpatching, change it to `false`.
  EOT

  type = bool

  default = false

  validation {
    condition     = var.hotpatching_enabled == false ? true : local.is_windows
    error_message = "Hotpatching can only be set for Windows virtual machines."
  }

  validation {
    condition     = (var.hotpatching_enabled && !var.bypass_platform_safety_checks_on_user_schedule_enabled) || (!var.hotpatching_enabled && var.bypass_platform_safety_checks_on_user_schedule_enabled) || (!var.hotpatching_enabled && !var.bypass_platform_safety_checks_on_user_schedule_enabled)
    error_message = "Only one of the following options can be set to true: either bypass_platform_safety_checks_on_user_schedule_enabled or hotpatching_enabled."
  }
}

variable "identity" {
  description = <<-EOT
    The Azure managed identity to assign to the virtual machine.

    Optional parameters:

    Parameter | Description
    -- | --
    `type` | Specifies the type of Managed Service Identity that should be configured on this Windows Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned` (to enable both).
    `identity_ids` | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine.
  EOT

  type = object({
    type         = optional(string)
    identity_ids = optional(list(string))
  })

  default = null
}

variable "image" {
  description = <<-EOT
    The URN or URN alias of the operating system image. Valid URN format is `Publisher:Offer:SKU:Version`. Use `az vm image list` to list possible URN values.

    Valid URN aliases are:
    - `CentOS85Gen2`
    - `Debian11`
    - `FlatcarLinuxFreeGen2`
    - `OpenSuseLeap154Gen2`
    - `RHELRaw8LVMGen2`
    - `SuseSles15SP5`
    - `Ubuntu2204`
    - `Ubuntu2404`
    - `Ubuntu2404Pro`
    - `Win2022Datacenter`
    - `Win2022AzureEditionCore`
    - `Win2019Datacenter`
    - `Win2016Datacenter`
    - `Win2012R2Datacenter`
    - `Win2012Datacenter`
  EOT

  type = string

  validation {
    condition     = length(split(":", var.image)) == 4 || contains(local.azure_quickstart_templates[*].urnAlias, var.image)
    error_message = "Unknown image urn alias \"${var.image}\". Valid aliases are: ${join(",", local.azure_quickstart_templates[*].urnAlias)}"
  }
}

variable "key_vault_id" {
  description = "Key Vault ID to store the generated admin password or admin SSH private key. Required when admin_password or admin_ssh_public_key is not set. Must not be set if either admin_password or admin_ssh_public_key is set."
  default     = null
  type        = string

  # validation {
  #   condition = var.key_vault_id == null ? (
  #     (var.authentication_type == "Password" && var.admin_password != null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key != null)
  #     ) : (
  #     (var.authentication_type == "Password" && var.admin_password == null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key == null)
  #   )
  #   error_message = "Invalid combination of key_vault_id, admin_password, and admin_ssh_public_key. If key_vault_id is null, admin_password or admin_ssh_public_key must be non-null. If key_vault_id is not null, admin_password and admin_ssh_public_key must be null."
  # }
}

variable "license_type" {
  description = <<-EOT
  Specifies the license type to be used for this Virtual Machine.

  Possible values:

  - For Windows images (using Azure Hybrid Use Benefit): `None`, `Windows_Client`, `Windows_Server`.
  - For Linux images: `RHEL_BYOS`, `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, `SLES_BYOS`, `SLES_SAP`, `SLES_HPC`.
  EOT

  type    = string
  default = null

  validation {
    condition = (
      var.license_type == null ? true :
      local.is_windows && contains(local.windows_license_types, var.license_type)
      ||
      local.is_linux && contains(local.linux_license_types, var.license_type)
    )
    error_message = <<-EOT
      Invalid value for 'license_type'.
      For Windows images, allowed values are: ${join(", ", local.windows_license_types)}.
      For Linux images, allowed values are: ${join(", ", local.linux_license_types)}.
    EOT
  }
}

variable "location" {
  description = "The Azure location where the virtual machine should reside."
  type        = string
}

variable "name" {
  description = "The name of the virtual machine. Changing this forces a new resource to be created."
  type        = string
}

variable "network_interface_ids" {
  default     = null
  description = "A list of network interface IDs to attach to this virtual machine. The first network interface ID in this list will be the primary network interface of the virtual machine. If `subnet_id` is set, then the network interface created by this module will be the primary network interface of the virtual machine."
  type        = list(string)
}

variable "operating_system" {
  default     = null
  description = "The virtual machine's operating system. Valid values are `Linux` or `Windows`. The default is `null`, which determines the operating system to use based on the virtual machine image offering."
  type        = string
}

variable "os_disk" {
  description = <<-EOT
    Operating system disk parameters.

    Optional parameters:

    Parameter | Description
    -- | --
    `caching` | The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
    `disk_encryption_set_id` | The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`.
    || **NOTE**: The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault.
    `disk_size_gb` | The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
    || **NOTE**: If specified this must be equal to or larger than the size of the Image the Virtual Machine is based on. When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space.
    `name` | The name which should be used for the Internal OS Disk. Default is `name` prefixed with `osdisk-`.
    `security_encryption_type` | Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`.
    || **NOTE**: `vtpm_enabled` must be set to true when `security_encryption_type` is specified.
    || **NOTE**: `encryption_at_host_enabled` cannot be set to true when `security_encryption_type` is set to `DiskWithVMGuestState`.
    `secure_vm_disk_encryption_set_id` | The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`.
    || **NOTE**: `secure_vm_disk_encryption_set_id` can only be specified `when security_encryption_type` is set to `DiskWithVMGuestState`.
    `storage_account_type` | The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`.
    `write_accelerator_enabled` | Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`.
    || **NOTE**: This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`.
  EOT

  type = object({
    caching                          = optional(string, "ReadWrite")
    disk_size_gb                     = optional(string)
    name                             = optional(string)
    storage_account_type             = optional(string, "Premium_LRS")
    disk_encryption_set_id           = optional(string)
    write_accelerator_enabled        = optional(bool, false)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
  })

  default = {
    caching                   = "ReadWrite"
    storage_account_type      = "Premium_LRS"
    write_accelerator_enabled = false
  }
}

variable "patch_assessment_mode" {
  description = <<-EOT
    Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault.

    **NOTE**: If the `patch_assessment_mode` is set to `AutomaticByPlatform` then the `provision_vm_agent` field must be set to `true`.

    Possible values:
    - `AutomaticByPlatform`
    - `ImageDefault`
  EOT

  type    = string
  default = "AutomaticByPlatform"
}

variable "patch_mode" {
  description = <<-EOT
    Specifies the mode of in-guest patching to this Windows Virtual Machine. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes).

    **NOTE**: If `patch_mode` is set to `AutomaticByPlatform` then `provision_vm_agent` must also be set to true. If the Virtual Machine is using a hotpatching enabled image the `patch_mode` must always be set to `AutomaticByPlatform`.

    Possible values:
    - `AutomaticByOS`
    - `AutomaticByPlatform`
    - `Manual`
  EOT

  type    = string
  default = "AutomaticByPlatform"
}

variable "plan" {
  description = <<-EOT
  The plan configuration for the Marketplace Image used to create a Virtual Machine.

  Required arguments:

  Argument | Description
  -- | --
  `name` | Specifies the Name of the Marketplace Image this Virtual Machine should be created from.
  `product` | Specifies the Product of the Marketplace Image this Virtual Machine should be created from.
  `publisher` | Specifies the Publisher of the Marketplace Image this Virtual Machine should be created from.
  EOT

  type = object({
    name      = string
    product   = string
    publisher = string
  })

  default = null
}

variable "private_ip_address" {
  description = "The static IP address to use. If not set (default), a dynamic IP address is assigned."
  default     = null
  type        = string
}

variable "provision_vm_agent" {
  description = <<-EOT
    Should the Azure VM Agent be provisioned on this Virtual Machine?

    **NOTE**: If `provision_vm_agent` is set to `false` then `allow_extension_operations` must also be set to `false`.
  EOT

  type    = bool
  default = true
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group which the Virtual Machine should be assigned to."

  type    = string
  default = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual machine should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "secure_boot_enabled" {
  description = "Specifies whether secure boot should be enabled on the virtual machine."

  type    = bool
  default = true
}

variable "size" {
  description = <<-EOT
    The [SKU](https://cloudprice.net/) to use for this virtual machine.

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
  EOT

  type    = string
  default = "Standard_DS1_v2"
}

variable "source_image_id" {
  description = <<-EOT
  The ID of the Image which this Virtual Machine should be created from.

  Possible Image ID types include:

  - Image ID
  - Shared Image ID
  - Shared Image Version ID
  - Community Gallery Image ID
  - Community Gallery Image Version ID
  - Shared Gallery Image IDs and Shared Gallery Image Version ID
  EOT

  type    = string
  default = null
}

variable "store_secret_in_key_vault" {
  description = "If set to `true`, the secrets generated by this module will be stored in the Key Vault specified by `key_vault_id`."
  type        = bool
  default     = true
}

variable "subnet_id" {
  default     = null
  description = "The ID of the subnet where the virtual machine's primary network interface should be located."
  type        = string

  validation {
    condition     = var.create_network_interface && var.subnet_id != null || !var.create_network_interface
    error_message = "The subnet_id is required if create_network_interface is enabled."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources in this module."

  type    = map(string)
  default = {}
}

variable "tags_virtual_machine" {
  description = "A mapping of tags which should be assigned to the Virtual Machine. This map will be merged with `tags`."

  type    = map(string)
  default = {}
}

variable "timezone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine, [the possible values are defined here](https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/). Setting timezone is not supported on Linux Virtual Machines."

  type    = string
  default = null

  validation {
    condition     = var.timezone == null ? true : local.is_windows
    error_message = "Timezone can only be set for Windows virtual machines."
  }
}

variable "virtual_machine_scale_set_id" {
  description = <<-EOT
    Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within.

    **NOTE**: To update `virtual_machine_scale_set_id` the Preview Feature `Microsoft.Compute/SingleFDAttachDetachVMToVmss` needs to be enabled, see the [documentation](https://review.learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-attach-detach-vm#enroll-in-the-preview) for more information.
  EOT

  type    = string
  default = null
}

variable "vtpm_enabled" {
  description = "Specifies if vTPM (virtual Trusted Platform Module) and Trusted Launch is enabled for the Virtual Machine."

  type    = bool
  default = true
}

variable "zone" {
  description = "Availability Zone in which this Windows Virtual Machine should be located."

  type    = string
  default = null
}
