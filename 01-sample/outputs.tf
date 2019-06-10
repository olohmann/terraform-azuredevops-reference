output "webapp_possible_outbound_ip_addresses" {
  value = "${azurerm_app_service.app.possible_outbound_ip_addresses}"
}

output "webapp_outbound_ip_addresses" {
  value = "${azurerm_app_service.app.outbound_ip_addresses}"
}
