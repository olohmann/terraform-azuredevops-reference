variable "prefix" {
  default     = "contoso"
  description = "A prefix used for all resources in this example"
}

variable "location" {
  default     = "West Europe"
  description = "The Azure region in which all resources in this example should be provisioned."
}

variable "tf_backend_network_access_rules" {
  type        = "list"
  description = "Defines the network level access rules for, e.g. the storage account. Format list of IP addresses and/or IP ranges. If nothing is defined, your current IP address will be added."
  default     = []
}

variable "tf_backend_add_current_client_ip_automatically" {
  type = "string"
  description = "Defines if the current client IP address (client that executes terraform) is automatically added to the trusted IP address range of the storage. If not, you need to make sure that the custom range allows the terraform client to actually reach the storage account."
  default = "true"
}

variable "tf_backend_location" {
  type        = "string"
  description = "If configured, overwrites the default location scheme for the backend resource group."
  default     = ""
}

variable "tf_backend_resource_group_name" {
  type        = "string"
  description = "If configured, overwrites the default naming scheme for the backend resource group."
  default     = ""
}

variable "tf_backend_storage_account_name" {
  type        = "string"
  description = "If configured, overwrites the default naming scheme for the backend resource group."
  default     = ""
}

variable "tf_backend_storage_container_name" {
  type        = "string"
  description = "If configured, overwrites the default naming scheme for the backend resource group."
  default     = ""
}
