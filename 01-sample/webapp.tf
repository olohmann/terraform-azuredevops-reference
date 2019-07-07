locals {
  asp_name = "${local.prefix_snake}-asp"
  app_name = "${local.prefix_snake}-app-${local.hash_suffix}"
  api_name = "${local.prefix_snake}-api-${local.hash_suffix}"

}

resource "azurerm_app_service_plan" "sp" {
  name                = "${local.asp_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  kind                = "Linux"
  reserved            = true # Mandatory for Linux plans

  sku {
    tier = "${var.app_service_plan_tier}"
    size = "${var.app_service_plan_size}"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${local.prefix_snake}-ai"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  application_type    = "Other"

  tags = "${map(
    "hidden-link:${azurerm_resource_group.rg.id}/providers/Microsoft.Web/sites/${local.api_name}",
    "Resource",
    "hidden-link:${azurerm_resource_group.rg.id}/providers/Microsoft.Web/sites/${local.app_name}",
    "Resource"
  )}"
}

// TODO: Enable new VNet Service Integration Feature
resource "azurerm_app_service" "app" {
  name                = "${local.prefix_snake}-app-${local.hash_suffix}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  app_service_plan_id = "${azurerm_app_service_plan.sp.id}"

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    APPINSIGHTS_INSTRUMENTATIONKEY      = "${azurerm_application_insights.app_insights.instrumentation_key}"
  }

  site_config {
    linux_fx_version = "DOCKER|nginx:latest"
    always_on        = true

    // Ensure WebApp is only accessible via AppGW.
    ip_restriction {
      ip_address = "${var.external_pip_name == "" ? azurerm_public_ip.pip.*.ip_address[0] : data.azurerm_public_ip.ex_pip.*.ip_address[0]}"
    }
  }
}

resource "azurerm_app_service" "api" {
  name                = "${local.prefix_snake}-api-${local.hash_suffix}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  app_service_plan_id = "${azurerm_app_service_plan.sp.id}"

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    APPINSIGHTS_INSTRUMENTATIONKEY      = "${azurerm_application_insights.app_insights.instrumentation_key}"
  }

  site_config {
    linux_fx_version = "DOCKER|nginx:latest"
    always_on        = true

    // Ensure WebApp is only accessible via AppGW.
    ip_restriction {
      ip_address = "${var.external_pip_name == "" ? azurerm_public_ip.pip.*.ip_address[0] : data.azurerm_public_ip.ex_pip.*.ip_address[0]}"
    }
  }

  connection_string {
    name  = "sql"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_sql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sql_db.name};Persist Security Info=False;User ID=${azurerm_sql_server.sql_server.administrator_login};Password=${azurerm_sql_server.sql_server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  connection_string {
    name  = "storage"
    type  = "Custom"
    value = "${azurerm_storage_account.sa.primary_connection_string}"
  }
}
