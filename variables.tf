variable "image" {
  description = "The name of the operating system image as a URN alias, URN. Valid URN format: `Publisher:Offer:Sku:Version`"
  type        = string

  validation {
    condition     = length(split(":", var.image)) == 4 || (length(split(":", var.image)) < 4 && contains(local.azure_common_image_aliases_json.*.urnAlias, var.image))
    error_message = "Unknown image urn alias \"${var.image}\". Valid aliases are: ${join(",", local.azure_common_image_aliases_json.*.urnAlias)}"
  }
}

variable "location" {
  description = "The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "name" {
  description = "The name of the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
}

variable "network_interface_ids" {
  description = "A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine."
  type        = list(string)
}

variable "operating_system" {
  default     = null
  description = "The operating system of the virtual machine to provision. Valid values are `Linux` or `Windows`. The default determines the operating system that will be used on the virtual machine image."
  type        = string

  validation {
    condition     = var.operating_system == null && (contains(local.linux_offers, local.image.offer) || contains(local.windows_offers, local.image.offer))
    error_message = "Cannot determine operating system for image offer \"${local.image.offer}\". Please specify input variable \"operating_system\" manually."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the Virtual Machine should be exist. Changing this forces a new resource to be created."
  type        = string
}

variable "size" {
  description = "The SKU which should be used for this Virtual Machine, such as `Standard_DS1_v2`."
  type        = string
  default     = "Standard_DS1_v2"
}
