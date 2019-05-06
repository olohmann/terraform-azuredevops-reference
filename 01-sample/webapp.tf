resource "azurerm_app_service_plan" "sp" {
  name                = "${local.prefix_snake}-asp"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${local.prefix_snake}-ai"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  application_type    = "Web"

  tags = "${map(
      "hidden-link:${azurerm_resource_group.rg.id}/providers/Microsoft.Web/sites/${local.prefix_snake}-${local.hash_suffix}", 
      "Resource"
    )}"
}

// TODO: Enable new VNet Service Integration Feature
resource "azurerm_app_service" "app" {
  name                = "${local.prefix_snake}-${local.hash_suffix}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  app_service_plan_id = "${azurerm_app_service_plan.sp.id}"

  site_config {
    default_documents = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "iisstart.htm", "default.aspx", "index.php", "hostingstart.html"]
    php_version       = "5.6"
  }

  app_settings {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.app_insights.instrumentation_key}"
  }
}
