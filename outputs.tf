output "admin_password" {
  description = "The admin password of the virtual machine."
  value       = local.admin_password
  sensitive   = true
}

output "admin_ssh_private_key" {
  description = "The private SSH key of the admin user."
  value       = local.admin_ssh_private_key
  sensitive   = true
}

output "admin_ssh_public_key" {
  description = "The piblic SSH key of the admin user."
  value       = local.admin_ssh_public_key
}

output "admin_username" {
  description = "The admin username of the virtual machine."
  value       = local.virtual_machine.admin_username
}

output "data_disks" {
  description = <<-EOT
    A list of data disks attached to the virtual machine. Each list element is an map with the following keys:

    Attributes:

    Attribute | Description
    -- | --
    `attachment_id` | The ID of the virtual machine data disk attachment
    `id`| The ID of the managed data disk.
    `name` | The name of the managed data disk.
  EOT

  value = [
    for resource in azurerm_managed_disk.this : {
      attachment_id = azurerm_virtual_machine_data_disk_attachment.this[resource.name].id
      id            = resource.id
      name          = resource.name
    }
  ]
}

output "id" {
  value       = local.virtual_machine.id
  description = "The ID of the virtual machine."
}

output "image" {
  description = <<-EOT
    The virtual machine operating system image to use.

    Attributes:

    Attribute | Description
    -- | --
     `architecture` | The image architecture.
     `offer` | The image offer.
     `operating_system` | The image operating system.
     `publisher` | The image publisher.
     `sku` | The image Stock Keeping Unit (SKU).
     `urn` | The full image URN.
     `urnAlias` | The image alias URN.
     || **NOTE**: Only [Azure Image Quick start templates](#azure-image-quick-start-templates) have an alias URN
     `version` | The image version.
  EOT

  value = local.image
}

output "key_vault_secret_id" {
  description = <<-EOT
    Key Vault Secret IDs for generated secrets.

    Attributes:

    Attribute | Description
    -- | --
    `admin_password` | The Key Vault secret ID for the password generated when variable `admin_password` is unset, and variable `authentication_type` is set to `Password`.
    `admin_ssh_private_key` | The Key Vault secret ID for the SSH private key generated when variable `admin_ssh_public_key` is unset, and variable `authentication_type` is set to `SSH`.
  EOT

  value = try({
    admin_password        = try(azurerm_key_vault_secret.this["Password"], null)
    admin_ssh_private_key = try(azurerm_key_vault_secret.this["SSH"], null)
  }, null)
}

output "network_interface" {
  description = <<-EOT
    The network interface create by this module, if `create_network_interface` ist set.

    Attributes:

    Attribute | Description
    -- | --
    `applied_dns_servers` | If the Virtual Machine using this Network Interface is part of an Availability Set, then this list will have the union of all DNS servers from all Network Interfaces that are part of the Availability Set.
    `id` | The ID of the Network Interface.
    `internal_domain_name_suffix` | The DNS name can be constructed by concatenating the VM name with this value.
    `mac_address` | The Media Access Control (MAC) Address of the Network Interface.
    `name` | The name of the Network Interface.
    `private_ip_address` | The first private IP address of the network interface.
    || **NOTE**: If `private_ip_address` is unset Azure will allocate an IP Address on Network Interface creation.
    `private_ip_addresses` | The private IP addresses of the network interface.
    || **NOTE**: If `private_ip_address` is unset Azure will allocate an IP Address on Network Interface creation.
  EOT

  value = one([
    for resource in azurerm_network_interface.this : {
      applied_dns_servers         = resource.applied_dns_servers
      id                          = resource.id
      internal_domain_name_suffix = resource.internal_domain_name_suffix
      mac_address                 = resource.mac_address
      name                        = resource.name
      private_ip_address          = resource.private_ip_address
      private_ip_addresses        = resource.private_ip_addresses
    }
  ])
}

output "private_ip_address" {
  description = "The primary private IP address assigned to this virtual machine."
  value       = local.virtual_machine.private_ip_address
}

output "private_ip_addresses" {
  description = "A list of all private IP addresses assigned to this virtual machine."
  value       = local.virtual_machine.private_ip_addresses
}

output "public_ip" {
  description = <<-EOT
    The public IP created by this module, if `create_public_ip_address` is set.

    Attribute | Description
    -- | --
    `id` | The ID of the Public IP.
    `ip_address` | The IP address value that was allocated.
  EOT

  value = one([
    for resource in azurerm_public_ip.this : {
      id         = resource.id
      ip_address = resource.ip_address
    }
  ])
}

output "public_ip_address" {
  description = "The primary public IP address assigned to this virtual machine."
  value       = local.virtual_machine.public_ip_address
}

output "public_ip_addresses" {
  description = "A list of all public IP addresses assigned to this virtual machine."
  value       = local.virtual_machine.public_ip_addresses
}

output "system_assigned_identity" {
  description = <<-EOT
    The primary user assigned identity of the virtual machine

    Attributes:

    Attribute | Description
    -- | --
    `principal_id` | The Principal ID of the system assigned identity.
    `tenant_id` | The Tenant ID of the system assigned identity.
  EOT

  value = one([
    for identity in local.virtual_machine.identity : {
      principal_id = identity.principal_id
      tenant_id    = identity.tenant_id
    }
  ])
}

output "user_assigned_identity" {
  description = <<-EOT
    The primary user assigned identity of the virtual machine

    Attributes:

    Attribute | Description
    -- | --
    `client_id` | The client id in uuid format of the user assigned identity.
    `id` | The resource id of the user assgined identity.
    `name` | The name of the user assigned identity.
    `principal_id` | The Principal ID of the user assigned identity.
    `tenant_id` | The Tenant ID of the user assigned identity.
  EOT

  value = one([
    for resource in azurerm_user_assigned_identity.this : {
      client_id    = resource.client_id
      id           = resource.id
      name         = resource.name
      principal_id = resource.principal_id
      tenant_id    = resource.tenant_id
    }
  ])
}

output "user_assigned_identity_ids" {
  description = "A list of all user assigned identities of the virtual machine."

  value = local.virtual_machine.identity[*].identity_ids
}

output "virtual_machine_extensions" {
  description = <<-EOT
    A list of virtual machine extensions installed on this virtual machine by this module. Each list element is a map with the following attributes:

    Attribute | Description
    -- | --
    `id` | The ID of the extension peering.
    `name` | The name of the extension peering.
    `publisher` | The publisher of the extension.
    `type` | The type of the extension.
    `type_handler_version` | The version of the extension.
    `auto_upgrade_minor_version` | Indicates whether the platform deploys the latest minor version update of the extension handler.
    `automatic_upgrade_enabled` | Indicates whether the extension is automatically updated whenever the publisher releases a new version.
  EOT

  value = [
    for resource in azurerm_virtual_machine_extension.this : {
      id                         = resource.id
      name                       = resource.name
      publisher                  = resource.publisher
      type                       = resource.type
      type_handler_version       = resource.type_handler_version
      auto_upgrade_minor_version = resource.auto_upgrade_minor_version
      automatic_upgrade_enabled  = resource.automatic_upgrade_enabled
    }
  ]
}

output "virtual_machine_id" {
  description = "A unique 128-bit identifier for this virtual machine (UUID)."
  value       = local.virtual_machine.virtual_machine_id
}
