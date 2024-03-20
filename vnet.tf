resource "azurerm_resource_group" "virtual_network_resource_group" {
  name     = "virtual_network_resource_group"
  location = var.resource_groups_location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "virtual_network"
  location            = azurerm_resource_group.virtual_network_resource_group.location
  resource_group_name = azurerm_resource_group.virtual_network_resource_group.name
  address_space       = [var.vnet_address_space]
}
