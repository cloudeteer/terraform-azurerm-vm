locals {
  # TODO: custom images
  azure_common_image_aliases_json = jsondecode(file("${path.module}/azure_common_images.json"))

  image = length(split(":", var.image)) == 4 ? {
    publisher = split(":", var.image)[0]
    offer     = split(":", var.image)[1]
    sku       = split(":", var.image)[2]
    version   = split(":", var.image)[3]
  } : local.azure_common_image_aliases_json[index(local.azure_common_image_aliases_json[*].urnAlias, var.image)]

  linux_offers = [
    "0001-com-ubuntu-server-jammy",
    "CentOS",
    "debian-11",
    "flatcar-container-linux-free",
    "openSUSE-leap-15-4",
    "RHEL",
    "sles-15-sp3",
  ]

  windows_offers = [
    "WindowsServer"
  ]

  is_linux   = try(contains(local.linux_offers, local.image.offer), var.operating_system == "Linux")
  is_windows = try(contains(local.windows_offers, local.image.offer), var.operating_system == "Windows")

  admin_password             = var.authentication_type == "Password" ? coalesce(var.admin_password, one(random_password.this[*].result)) : null
  admin_ssh_public_key       = var.authentication_type == "SSH" ? coalesce(var.admin_ssh_public_key, one(tls_private_key.this[*].public_key_openssh)) : null
  admin_ssh_private_key      = local.create_ssh_key_pair ? one(tls_private_key.this[*].private_key_openssh) : null
  backup_recovery_vault_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[8] : null
  backup_resource_group_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[4] : null
  create_password            = var.authentication_type == "Password" && var.admin_password == null
  create_ssh_key_pair        = var.authentication_type == "SSH" && var.admin_ssh_public_key == null
  network_interface_ids      = concat(azurerm_network_interface.this[*].id, var.network_interface_ids != null ? var.network_interface_ids : [])
  virtual_machine            = local.is_linux ? azurerm_linux_virtual_machine.this[0] : (local.is_windows ? azurerm_windows_virtual_machine.this[0] : null)
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_password                  = local.admin_password
  admin_username                  = var.admin_username
  computer_name                   = coalesce(var.computer_name, split("-", trimprefix(var.name, "vm-"))[0])
  disable_password_authentication = false
  network_interface_ids           = local.network_interface_ids
  size                            = var.size

  dynamic "admin_ssh_key" {
    for_each = var.authentication_type == "SSH" ? [true] : []
    content {
      username   = var.admin_username
      public_key = local.admin_ssh_public_key
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics.enable == true ? [true] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
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

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }

  lifecycle {
    ignore_changes = [os_disk[0].name]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_password        = local.admin_password
  admin_username        = var.admin_username
  computer_name         = coalesce(var.computer_name, split("-", trimprefix(var.name, "vm-"))[0])
  network_interface_ids = local.network_interface_ids
  size                  = var.size

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics.enable == true ? [true] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
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

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }

  lifecycle {
    ignore_changes = [os_disk[0].name]
  }
}

resource "azurerm_network_interface" "this" {

  count = var.create_network_interface ? 1 : 0

  name                = "nic-${trimprefix(var.name, "vm-")}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = var.private_ip_address == null ? "Dynamic" : "Static"
    subnet_id                     = var.subnet_id
  }
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
  count = local.create_password || local.create_ssh_key_pair ? 1 : 0

  name         = "${var.name}-${var.admin_username}-${lower(var.authentication_type)}"
  content_type = var.authentication_type
  key_vault_id = var.key_vault_id
  value        = coalesce(local.admin_password, local.admin_ssh_private_key)
}
