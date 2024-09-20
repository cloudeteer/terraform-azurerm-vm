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

  value = [for resource in azurerm_managed_disk.this : {
    attachment_id = azurerm_virtual_machine_data_disk_attachment.this[resource.name].id
    id            = resource.id
    name          = resource.name
  }]
}

output "id" {
  value       = local.virtual_machine.id
  description = "The ID of the virtual machine."
}

output "image" {
  value = local.image
}

output "key_vault_secret_id" {
  value = try(azurerm_key_vault_secret.this[0].id, null)
}

output "network_interface" {
  value = one([for resource in azurerm_network_interface.this : {
    applied_dns_servers         = resource.applied_dns_servers
    id                          = resource.id
    internal_domain_name_suffix = resource.internal_domain_name_suffix
    mac_address                 = resource.mac_address
    name                        = resource.name
    private_ip_address          = resource.private_ip_address
    private_ip_addresses        = resource.private_ip_addresses
  }])
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
  value = one([for resource in azurerm_public_ip.this : {
    id         = resource.id
    ip_address = resource.ip_address
    fqdn       = resource.fqdn
  }])
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

  value = one([for identity in local.virtual_machine.identity : {
    principal_id = identity.principal_id
    tenant_id    = identity.tenant_id
  }])
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

  value = one([for resource in azurerm_user_assigned_identity.this : {
    client_id    = resource.client_id
    id           = resource.id
    name         = resource.name
    principal_id = resource.principal_id
    tenant_id    = resource.tenant_id
  }])
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

  value = [for resource in azurerm_virtual_machine_extension.this : {
    id                         = resource.id
    name                       = resource.name
    publisher                  = resource.publisher
    type                       = resource.type
    type_handler_version       = resource.type_handler_version
    auto_upgrade_minor_version = resource.auto_upgrade_minor_version
    automatic_upgrade_enabled  = resource.automatic_upgrade_enabled
  }]
}

output "virtual_machine_id" {
  description = "A unique 128-bit identifier for this virtual machine (UUID)."
  value       = local.virtual_machine.virtual_machine_id
}
