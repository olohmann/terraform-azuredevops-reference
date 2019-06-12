resource "random_string" "password" {
  length = 16
  special = false
  min_upper = "2"
  min_lower = "2"
  min_numeric = "2"
}

// TODO: Sizing as variable
resource "azurerm_sql_server" "sql_server" {
  name                         = "${local.prefix_snake}-${local.hash_suffix}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  location                     = "${azurerm_resource_group.rg.location}"
  version                      = "12.0"
  administrator_login          = "azureuser"
  administrator_login_password = "${random_string.password.result}"
}

// TODO: AAD Login
resource "azurerm_sql_database" "sql_db" {
  name                = "db"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  server_name         = "${azurerm_sql_server.sql_server.name}"
}

resource "azurerm_sql_firewall_rule" "sql_firewall_ip_rule" {
  count               = "${length(local.ip_rules_pairs_list) / 2}"
  name                = "firewall-rule-${count.index}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_sql_server.sql_server.name}"
  start_ip_address    = "${element(local.ip_rules_pairs_list, count.index * 2)}"
  end_ip_address      = "${element(local.ip_rules_pairs_list, count.index * 2 + 1)}"
}

// TODO: Use provided firewall rules
/* Azure Service Access: Convention 0.0.0.0/0.0.0.0 */
resource "azurerm_sql_firewall_rule" "sql_firewall" {
  name                = "firewall-rule-azure-services"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_sql_server.sql_server.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
