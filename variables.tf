variable "backup_policy_id" {
  description = "The ID of the backup policy to use."
  type        = string
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
    - `SuseSles15SP3`
    - `Ubuntu2204`
    - `Win2022Datacenter`
    - `Win2022AzureEditionCore`
    - `Win2019Datacenter`
    - `Win2016Datacenter`
    - `Win2012R2Datacenter`
    - `Win2012Datacenter`
    - `Win2008R2SP1`
  EOT

  type = string

  validation {
    condition     = length(split(":", var.image)) == 4 || (length(split(":", var.image)) < 4 && contains(local.azure_common_image_aliases_json[*].urnAlias, var.image))
    error_message = "Unknown image urn alias \"${var.image}\". Valid aliases are: ${join(",", local.azure_common_image_aliases_json[*].urnAlias)}"
  }
}

variable "location" {
  description = "The Azure location where the virtual machine should reside. Changing this forces a new resource to be created."
  type        = string
}

variable "name" {
  description = "The name of the virtual machine. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual machine should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "admin_password" {
  description = "Password to use for the local administrator on this virtual machine. If not set, a password will be generated and stored in the Key Vault specified by key_vault_id."
  default     = null
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Public key to use for SSH authentication. Must be at least 2048-bit and in ssh-rsa format."
  default     = null
  type        = string
}

variable "admin_username" {
  default     = "azureadmin"
  description = "Username of the local administrator for the virtual machine."
  type        = string
}

variable "authentication_type" {
  description = "Specifies the authentication type to use. Valid options are `SSH` or `Password`. Windows virtual machines support only `Password`."
  default     = "Password"
  type        = string

  validation {
    condition     = var.authentication_type == "Password" || (var.authentication_type == "SSH" && !local.is_windows)
    error_message = "On Windows operating systems, authentication_type = \"SSH\" is not supported. Use authentication_type = \"Password\" for Windows images."
  }
}

variable "computer_name" {
  description = <<-EOT
    Specifies the hostname to use for this virtual machine. If unspecified, it defaults to the first subscrings up to the `-` char without the `vm-` prefix of `name`. If this value is not a valid hostname, you must specify a hostname.

    Example: If `name` is `vm-example-prd-gwc-01`, `computer_name` will be `example`.
  EOT

  type    = string
  default = null
}

variable "key_vault_id" {
  description = "Key Vault ID to store the generated admin password or admin SSH private key. Required when admin_password or admin_ssh_public_key is not set. Must not be set if either admin_password or admin_ssh_public_key is set."
  default     = null
  type        = string

  validation {
    condition = var.key_vault_id == null ? (
      (var.authentication_type == "Password" && var.admin_password != null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key != null)
      ) : (
      (var.authentication_type == "Password" && var.admin_password == null) || (var.authentication_type == "SSH" && var.admin_ssh_public_key == null)
    )
    error_message = "Invalid combination of key_vault_id, admin_password, and admin_ssh_public_key. If key_vault_id is null, admin_password or admin_ssh_public_key must be non-null. If key_vault_id is not null, admin_password and admin_ssh_public_key must be null."
  }
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

  validation {
    condition     = var.operating_system == null && (contains(local.linux_offers, local.image.offer) || contains(local.windows_offers, local.image.offer))
    error_message = "Cannot determine operating system for image offer \"${local.image.offer}\". Please specify input variable \"operating_system\" manually."
  }
}

variable "private_ip_address" {
  description = "The static IP address to use. If not set (default), a dynamic IP address is assigned."
  default     = null
  type        = string
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

variable "subnet_id" {
  default     = null
  description = "The ID of the subnet where the virtual machine's primary network interface should be located."
  type        = string

  validation {
    condition     = var.subnet_id != null || var.network_interface_ids != null
    error_message = "The subnet_id is required if network_interface_ids is not set."
  }
}
