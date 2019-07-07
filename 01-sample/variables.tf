variable "resource_group_name" {
  default     = ""
  description = "Optional value to define a pre-set resource group for the deployment."
}

variable "prefix" {
  default     = "contoso"
  description = "A prefix used for all resources in this example"
}

variable "location" {
  default     = "West Europe"
  description = "The Azure region in which all resources in this example should be provisioned."
}

variable "ip_rules" {
  type        = "list"
  default     = []
  description = "Additional IP whitelist rules for, e.g. Azure Storage. Supports CIDR entries."
}

variable "ip_rules_pairs" {
  type        = "list"
  default     = []
  description = "Additional IP whitelist rules for Azure SQL Server DB. Requires pairs of start and end entries (i.e. list mod 2 == 0). Example '1.1.1.1, 1.1.1.2' - .1 is start, .2 is end => 2 IP addresses whitelisted."
}

variable "external_pip_name" {
  type        = "string"
  description = "If configured, the Azure Firewall resource will reference the externally create Puplic IP instead of creating a new one."
  default     = ""
}

variable "external_pip_resource_group" {
  type        = "string"
  description = "If configured, the Azure Firewall resource will reference the externally create Puplic IP instead of creating a new one."
  default     = ""
}

variable "app_gw_domain_name_label" {
  type        = "string"
  description = "Domain Name Label for Application Gateway PIP."
  default     = ""
}

variable "app_service_plan_tier" {
  type        = "string"
  description = "The tier of the App Service Plan."
  default     = "Standard"
}

variable "app_service_plan_size" {
  type        = "string"
  description = "The size of the App Service Plan."
  default     = "S1"
}
