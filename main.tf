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

  is_linux      = try(contains(local.linux_offers, local.image.offer), var.operating_system == "Linux")
  is_windows    = try(contains(local.windows_offers, local.image.offer), var.operating_system == "Windows")
  enable_backup = var.backup_policy_id != null

  backup_recovery_vault_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[8] : null
  backup_resource_group_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[4] : null
  network_interface_ids      = concat(azurerm_network_interface.this[*].id, var.network_interface_ids != null ? var.network_interface_ids : [])
  virtual_machine            = local.is_linux ? azurerm_linux_virtual_machine.this[0] : (local.is_windows ? azurerm_windows_virtual_machine.this[0] : null)
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_password                  = "Pa$$w0rd"
  admin_username                  = "azureadmin"
  computer_name                   = coalesce(var.computer_name, split("-", trimprefix(var.name, "vm-"))[0])
  disable_password_authentication = false
  network_interface_ids           = local.network_interface_ids
  size                            = var.size

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_password        = "Pa$$w0rd"
  admin_username        = "azureadmin"
  computer_name         = coalesce(var.computer_name, split("-", trimprefix(var.name, "vm-"))[0])
  network_interface_ids = local.network_interface_ids
  size                  = var.size

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }
}

resource "azurerm_network_interface" "this" {

  count = var.subnet_id != null ? 1 : 0

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

  count = local.enable_backup ? 1 : 0

  resource_group_name = local.backup_resource_group_name

  backup_policy_id    = var.backup_policy_id
  recovery_vault_name = local.backup_recovery_vault_name
  source_vm_id        = local.virtual_machine.id
}
