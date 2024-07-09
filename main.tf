locals {
  image_urn_aliases = {
    Debian11 = {
      publisher = "Debian"
      offer     = "debian-11"
      sku       = "11-backports-gen2"
      version   = "latest"
    }
    Ubuntu2204 = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    Win2022Datacenter = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
  }

  image = length(split(":", var.image)) == 4 ? {
    publisher = split(":", var.image)[0]
    offer     = split(":", var.image)[1]
    sku       = split(":", var.image)[2]
    version   = split(":", var.image)[3]
  } : local.image_urn_aliases[var.image]

  linux_offers = [
    "0001-com-ubuntu-server-jammy",
    "debian-11"
  ]

  windows_offers = [
    "WindowsServer"
  ]

  is_linux   = try(contains(local.linux_offers, local.image.offer), var.operating_system == "Linux")
  is_windows = try(contains(local.windows_offers, local.image.offer), var.operating_system == "Windows")
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_username        = "azureadmin"
  network_interface_ids = var.network_interface_ids
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

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  admin_password        = "Pa$$w0rd"
  admin_username        = "azureadmin"
  network_interface_ids = var.network_interface_ids
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
