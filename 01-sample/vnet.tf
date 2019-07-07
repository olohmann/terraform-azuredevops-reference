resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix_snake}-${local.hash_suffix}-vnet"
  address_space       = ["10.0.0.0/20"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet_app_gw" {
  name                 = "subnet_app_gw"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.0.0/24"
}

/*
// Service Delegation allows the new AppService VNet Integration feature.
resource "azurerm_subnet" "subnet_app_svc" {
  name                 = "subnet_app_svc"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
  service_endpoints    = ["Microsoft.Sql", "Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Storage"]
  delegation {
    name = "default"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
*/
