# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "ampls" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "ampls" {
  name                = var.vnet_name
  location            = azurerm_resource_group.ampls.location
  resource_group_name = azurerm_resource_group.ampls.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Subnet for Private Endpoints
# Private endpoint network policies must be disabled on the subnet so that
# the platform can apply NSG rules to the private endpoint NIC.
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "private_endpoints" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.ampls.name
  virtual_network_name = azurerm_virtual_network.ampls.name
  address_prefixes     = var.subnet_address_prefixes

  private_endpoint_network_policies = "Disabled"
}
