locals {
  admin_password             = var.authentication_type == "Password" ? coalesce(var.admin_password, one(random_password.this[*].result)) : null
  admin_ssh_public_key       = var.authentication_type == "SSH" ? coalesce(var.admin_ssh_public_key, one(tls_private_key.this[*].public_key_openssh)) : null
  admin_ssh_private_key      = local.create_ssh_key_pair ? one(tls_private_key.this[*].private_key_openssh) : null
  backup_recovery_vault_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[8] : null
  backup_resource_group_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[4] : null
  create_password            = var.authentication_type == "Password" && var.admin_password == null
  create_ssh_key_pair        = var.authentication_type == "SSH" && var.admin_ssh_public_key == null
  network_interface_ids      = concat(azurerm_network_interface.this[*].id, var.network_interface_ids != null ? var.network_interface_ids : [])
  virtual_machine            = local.is_linux ? azurerm_linux_virtual_machine.this[0] : (local.is_windows ? azurerm_windows_virtual_machine.this[0] : null)
  create_identity            = strcontains(try(var.identity.type, ""), "UserAssigned") && length(try(coalescelist(var.identity.identity_ids, []), [])) == 0

  data_disks = [for _index, element in var.data_disks : merge(element, {
    name = coalesce(element.name, format("disk-%s-%02.0f", trimprefix(var.name, "vm-"), sum([_index, 1])))
  })]
}

# TODO: Remove this trivy-ignore line
# trivy:ignore:avd-azu-0039
resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, var.tags_virtual_machine)

  admin_password                                         = local.admin_password
  admin_username                                         = var.admin_username
  allow_extension_operations                             = var.allow_extension_operations
  availability_set_id                                    = var.availability_set_id
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  computer_name                                          = var.computer_name
  custom_data                                            = var.custom_data
  disable_password_authentication                        = false
  encryption_at_host_enabled                             = var.encryption_at_host_enabled
  license_type                                           = var.license_type
  network_interface_ids                                  = local.network_interface_ids
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = var.patch_mode
  provision_vm_agent                                     = var.provision_vm_agent
  proximity_placement_group_id                           = var.proximity_placement_group_id
  secure_boot_enabled                                    = var.secure_boot_enabled
  size                                                   = var.size
  source_image_id                                        = var.source_image_id
  virtual_machine_scale_set_id                           = var.virtual_machine_scale_set_id
  vtpm_enabled                                           = var.vtpm_enabled
  zone                                                   = var.zone

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities[*]
    content {
      ultra_ssd_enabled   = var.additional_capabilities.ultra_ssd_enabled
      hibernation_enabled = var.additional_capabilities.hibernation_enabled
    }
  }

  dynamic "admin_ssh_key" {
    for_each = var.authentication_type == "SSH" ? [true] : []
    content {
      username   = var.admin_username
      public_key = local.admin_ssh_public_key
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics.enabled ? [true] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
    }
  }

  dynamic "identity" {
    for_each = try(var.identity.type, null) != null ? [true] : []
    content {
      type         = var.identity.type
      identity_ids = try(coalescelist(var.identity.identity_ids, azurerm_user_assigned_identity.this[*].id), null)
    }
  }

  os_disk {
    caching                          = var.os_disk.caching
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = coalesce(var.os_disk.name, "osdisk-${trimprefix(var.name, "vm-")}")
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    storage_account_type             = var.os_disk.storage_account_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
  }

  dynamic "plan" {
    for_each = var.plan[*]
    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [true] : []
    content {
      publisher = local.image.publisher
      offer     = local.image.offer
      sku       = local.image.sku
      version   = local.image.version
    }
  }

  lifecycle {
    ignore_changes = [
      # Gallery applications are installed via Azure policy.
      gallery_application,

      # Disk name may change during restore or other manual operations.
      os_disk[0].name,
    ]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, var.tags_virtual_machine)

  admin_password                                         = local.admin_password
  admin_username                                         = var.admin_username
  allow_extension_operations                             = var.allow_extension_operations
  availability_set_id                                    = var.availability_set_id
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  computer_name                                          = var.computer_name
  custom_data                                            = var.custom_data
  enable_automatic_updates                               = var.enable_automatic_updates
  encryption_at_host_enabled                             = var.encryption_at_host_enabled
  license_type                                           = var.license_type
  network_interface_ids                                  = local.network_interface_ids
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = var.patch_mode
  provision_vm_agent                                     = var.provision_vm_agent
  proximity_placement_group_id                           = var.proximity_placement_group_id
  secure_boot_enabled                                    = var.secure_boot_enabled
  size                                                   = var.size
  source_image_id                                        = var.source_image_id
  timezone                                               = var.timezone
  virtual_machine_scale_set_id                           = var.virtual_machine_scale_set_id
  vtpm_enabled                                           = var.vtpm_enabled
  zone                                                   = var.zone

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities[*]
    content {
      ultra_ssd_enabled   = var.additional_capabilities.ultra_ssd_enabled
      hibernation_enabled = var.additional_capabilities.hibernation_enabled
    }
  }

  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_content[*]
    content {
      content = var.additional_unattend_content.content
      setting = var.additional_unattend_content.setting
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics.enabled ? [true] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
    }
  }

  dynamic "identity" {
    for_each = try(var.identity.type, null) != null ? [true] : []
    content {
      type         = var.identity.type
      identity_ids = try(coalescelist(var.identity.identity_ids, azurerm_user_assigned_identity.this[*].id), null)
    }
  }

  os_disk {
    caching                          = var.os_disk.caching
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = coalesce(var.os_disk.name, "osdisk-${trimprefix(var.name, "vm-")}")
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    storage_account_type             = var.os_disk.storage_account_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
  }

  dynamic "plan" {
    for_each = var.plan[*]
    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [true] : []
    content {
      publisher = local.image.publisher
      offer     = local.image.offer
      sku       = local.image.sku
      version   = local.image.version
    }
  }

  lifecycle {
    ignore_changes = [
      # Gallery applications are installed via Azure policy.
      gallery_application,

      # Disk name may change during restore or other manual operations.
      os_disk[0].name,
    ]
  }
}

resource "azurerm_network_interface" "this" {

  count = var.create_network_interface ? 1 : 0

  name                = "nic-${trimprefix(var.name, "vm-")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = var.private_ip_address == null ? "Dynamic" : "Static"
    public_ip_address_id          = one(azurerm_public_ip.this[*].id)
    subnet_id                     = var.subnet_id
  }
}

resource "azurerm_public_ip" "this" {
  count = var.create_public_ip_address ? 1 : 0

  name                = "nic-${trimprefix(var.name, "vm-")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
  sku_tier          = "Regional"
}

resource "azurerm_backup_protected_vm" "this" {
  count = var.enable_backup_protected_vm ? 1 : 0

  resource_group_name = local.backup_resource_group_name

  backup_policy_id    = var.backup_policy_id
  recovery_vault_name = local.backup_recovery_vault_name
  source_vm_id        = local.virtual_machine.id
}

resource "random_password" "this" {
  count  = local.create_password ? 1 : 0
  length = 24
}

resource "tls_private_key" "this" {
  count     = local.create_ssh_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#trivy:ignore:avd-azu-0017
#trivy:ignore:avd-azu-0013
resource "azurerm_key_vault_secret" "this" {
  count = var.store_secret_in_key_vault ? 1 : 0

  name         = "${var.name}-${var.admin_username}-${lower(var.authentication_type)}"
  content_type = var.authentication_type
  key_vault_id = var.key_vault_id
  value        = coalesce(local.admin_password, local.admin_ssh_private_key)
}

resource "azurerm_user_assigned_identity" "this" {
  count = local.create_identity ? 1 : 0

  name                = "id-${trimprefix(var.name, "vm-")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_managed_disk" "this" {
  for_each = { for element in local.data_disks : element.name => element }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = { for element in local.data_disks : element.name => element }

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = local.virtual_machine.id
  lun                = each.value.lun
  caching            = each.value.caching
}

resource "azurerm_virtual_machine_extension" "this" {

  for_each = { for element in [
    {
      name                       = "NetworkWatcherAgent"
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = local.is_windows ? "NetworkWatcherAgentWindows" : (local.is_linux ? "NetworkWatcherAgentLinux" : null)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
    {
      name                       = "AzureMonitorAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = local.is_windows ? "AzureMonitorWindowsAgent" : (local.is_linux ? "AzureMonitorLinuxAgent" : null)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
    {
      name                       = "AzurePolicy"
      publisher                  = "Microsoft.GuestConfiguration"
      type                       = local.is_windows ? "ConfigurationforWindows" : (local.is_linux ? "ConfigurationForLinux" : null)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
    local.is_windows ? {
      name                       = "AntiMalware"
      publisher                  = "Microsoft.Azure.Security"
      type                       = "IaaSAntimalware"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = false
    } : null
  ] : element.name => element if try(element.type, null) != null && contains(var.extensions, try(element.name, "")) }

  virtual_machine_id = local.virtual_machine.id

  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled  = each.value.automatic_upgrade_enabled
  name                       = each.value.name
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version
}
