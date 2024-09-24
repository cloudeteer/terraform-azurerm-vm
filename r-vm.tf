locals {
  virtual_machine = (local.is_linux ? azurerm_linux_virtual_machine.this[0] :
    (local.is_windows ? azurerm_windows_virtual_machine.this[0] : null)
  )
}

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
  disable_password_authentication                        = !strcontains(var.authentication_type, "Password") # trivy:ignore:avd-azu-0039
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
  hotpatching_enabled                                    = var.hotpatching_enabled
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
