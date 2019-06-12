variable "resource_group_name" {
  default = ""
  description = "Optional value to define a pre-set resource group for the deployment."
}

variable "prefix" {
  default = "contoso"
  description = "A prefix used for all resources in this example"
}

variable "location" {
  default     = "West Europe"
  description = "The Azure region in which all resources in this example should be provisioned."
}

variable "ip_rules" {
  type = "list"
  default     = []
  description = "Additional IP whitelist rules for, e.g. Azure Storage. Supports CIDR entries."
}

variable "ip_rules_pairs" {
  type = "list"
  default = []
  description = "Additional IP whitelist rules for Azure SQL Server DB. Requires pairs of start and end entries (i.e. list mod 2 == 0). Example '1.1.1.1, 1.1.1.2' - .1 is start, .2 is end => 2 IP addresses whitelisted."
}
