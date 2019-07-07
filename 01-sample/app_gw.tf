locals {
  external_pip_id  = "${data.azurerm_subscription.current.id}/resourceGroups/${var.external_pip_resource_group}/providers/Microsoft.Network/publicIPAddresses/${var.external_pip_name}"
  generated_pip_id = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Network/publicIPAddresses/${local.prefix_snake}-${local.hash_suffix}-pip"
}

// Only create a new PIP if no external PIP was provided.
resource "azurerm_public_ip" "pip" {
  count               = "${var.external_pip_name == "" ? 1 : 0}"
  name                = "${local.prefix_snake}-${local.hash_suffix}-pip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.app_gw_domain_name_label == "" ? "${local.prefix_snake}-${local.hash_suffix}" : var.app_gw_domain_name_label}"
}

data "azurerm_public_ip" "ex_pip" {
  count               = "${var.external_pip_name == "" ? 0 : 1}"
  name                = "${var.external_pip_name}"
  resource_group_name = "${var.external_pip_resource_group}"
}

locals {
  backend_address_pool_name      = "backend_address_pool"
  frontend_port_name             = "frontend_port"
  frontend_ip_configuration_name = "frontend_ip_config"
  http_setting_name              = "http_setting"
  listener_name                  = "listener"
  request_routing_rule_name      = "request_routing_table_rule"
  redirect_configuration_name    = "redirect_config"
}

resource "azurerm_application_gateway" "app_gw" {
  name                = "${local.prefix_snake}-${local.hash_suffix}-app-gw"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = "${azurerm_subnet.subnet_app_gw.id}"
  }

  frontend_port {
    name = "${local.frontend_port_name}"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${var.external_pip_name == "" ? local.generated_pip_id : local.external_pip_id}"
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name}-app"
    fqdns = ["${azurerm_app_service.app.default_site_hostname}"]
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name}-api"
    fqdns = ["${azurerm_app_service.api.default_site_hostname}"]
  }

  backend_http_settings {
    name                                = "${local.http_setting_name}-api"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "${local.http_setting_name}-app"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "${local.listener_name}-http"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}"
    protocol                       = "Http"
  }

  # TODO: Configure this later
  # probe {
  #   name = "api-health-probe"
  #   pick_host_name_from_backend_http_settings = true
  #   protocol = "Https"
  #   path = "/api/health/ping"
  #   interval = "60"
  #   timeout = "10"
  #   unhealthy_threshold = "3"
  # }

  request_routing_rule {
    name               = "${local.request_routing_rule_name}-app-http"
    rule_type          = "PathBasedRouting"
    http_listener_name = "${local.listener_name}-http"

    url_path_map_name = "urlmap"
  }

  # Configure the default URL mapping for all components
  url_path_map {
    name                               = "urlmap"
    default_backend_address_pool_name  = "${local.backend_address_pool_name}-app"
    default_backend_http_settings_name = "${local.http_setting_name}-app"

    # Configuration for the main REST API
    path_rule {
      name                       = "${local.request_routing_rule_name}-api"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "${local.backend_address_pool_name}-api"
      backend_http_settings_name = "${local.http_setting_name}-api"
    }
  }
}
