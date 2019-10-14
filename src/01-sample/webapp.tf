locals {
  asp_name = local.prefix_snake
  ai_name = local.prefix_snake
  app_name = "${local.prefix_snake}-${local.hash_suffix}"
}

resource "azurerm_app_service_plan" "sp" {
  name                = local.asp_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
  reserved            = true # Mandatory for Linux plans

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = local.ai_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "Other"

  tags = "${map(
    "hidden-link:${azurerm_resource_group.rg.id}/providers/Microsoft.Web/sites/${local.app_name}",
    "Resource"
  )}"
}

// TODO: Enable new VNet Service Integration Feature
resource "azurerm_app_service" "app" {
  name                = local.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.sp.id

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    APPINSIGHTS_INSTRUMENTATIONKEY      = "${azurerm_application_insights.app_insights.instrumentation_key}"
  }

  site_config {
    linux_fx_version = "DOCKER|nginx:latest"
    always_on        = true
  }
}
