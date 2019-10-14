locals {

  // A snake-cased prefix for resources that also integrates the Terraform Workspace 
  // (e.g. dev, qa, prod) into the resource name.
  prefix_snake = lower("${terraform.workspace}-${var.prefix}")

  // A flat prefix for resources that also integrates the Terraform Workspace 
  // (e.g. dev, qa, prod) into the resource name. Useful for resources that
  // don't allow hyphens (e.g. Azure Storage or Azure Container Registry).
  prefix_flat = lower("${terraform.workspace}${var.prefix}")

  // The flat lower-cased version of the Azure Location string (West Europe -> westeurope)
  location = lower(replace(var.location, " ", ""))

  // The idea of this hash value is to use it as a pseudo-random suffix for
  // resources with domain name requirements. It will stay constant over re-deployments
  // per individual resource group. This is useful for CName DNS entries.
  hash_suffix = lower(substr(sha256(azurerm_resource_group.rg.id), 0, 6))

  // Truncated version to fit Storage Accounts naming requirements (<=24 chars)).
  prefix_flat_with_suffix_truncated = "${substr(local.prefix_flat, 0, min(18, length(local.prefix_flat)))}${local.hash_suffix}"

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${local.prefix_snake}-rg"
}
