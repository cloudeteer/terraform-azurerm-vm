resource "azurerm_virtual_network" "tftest" {
  name                = "vnet-tftest-dev-we-01"
  location            = azurerm_resource_group.tftest.location
  resource_group_name = azurerm_resource_group.tftest.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tftest" {
  name                = "snet-tftest-dev-we-01"
  resource_group_name = azurerm_resource_group.tftest.name

  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.tftest.name
}

output "subnet_id" {
  value = azurerm_subnet.tftest.id
}
