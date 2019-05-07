resource "azurerm_storage_account" "sa" {
  name                      = "${local.prefix_flat_with_suffix_truncated}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  location                  = "${azurerm_resource_group.rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_blob_encryption    = true
  enable_file_encryption    = true
  enable_https_traffic_only = true

  account_kind = "StorageV2"
  access_tier  = "Hot"

  network_rules {
    ip_rules = ["${local.ip_rules_list}"]
  }
}
