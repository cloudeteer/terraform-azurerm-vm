variable "image" {
  description = <<-EOD
  The name of the operating system image as a URN or URN alias.

  Valid URN format is `Publisher:Offer:SKU:Version`.

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

  Use `az vm image list` to list the possible values.
  EOD
  type        = string

  validation {
    condition     = length(split(":", var.image)) == 4 || (length(split(":", var.image)) < 4 && contains(local.azure_common_image_aliases_json.*.urnAlias, var.image))
    error_message = "Unknown image urn alias \"${var.image}\". Valid aliases are: ${join(",", local.azure_common_image_aliases_json.*.urnAlias)}"
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

variable "network_interface_ids" {
  description = "A list of network interface IDs to be attached to this virtual machine. The first network interface ID in this list will be the primary network interface on the virtual machine."
  type        = list(string)
}

variable "operating_system" {
  default     = null
  description = "The virtual machine's operating system. Valid values are `Linux' or `Windows'. The default is `null', which determines the operating system to use based on the virtual machine image offering."
  type        = string

  validation {
    condition     = var.operating_system == null && (contains(local.linux_offers, local.image.offer) || contains(local.windows_offers, local.image.offer))
    error_message = "Cannot determine operating system for image offer \"${local.image.offer}\". Please specify input variable \"operating_system\" manually."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual machine should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "size" {
  description = "The SKU to use for this virtual machine, such as `Standard_DS1_v2`."
  type        = string
  default     = "Standard_DS1_v2"
}
