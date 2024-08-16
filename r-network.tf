locals {
  network_interface_ids = concat(
    azurerm_network_interface.this[*].id,
    (var.network_interface_ids != null ? var.network_interface_ids : [])
  )

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
