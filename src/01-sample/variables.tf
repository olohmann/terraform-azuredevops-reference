variable "resource_group_name" {
  default     = ""
  description = "Optional value to define a pre-set resource group for the deployment."
  type = string
}

variable "prefix" {
  default     = "contoso"
  description = "A prefix used for all resources in this example"
  type = string
}

variable "location" {
  default     = "West Europe"
  description = "The Azure region in which all resources in this example should be provisioned."
  type = string
}

variable "app_service_plan_tier" {
  description = "The tier of the App Service Plan."
  default     = "Standard"
  type        = "string"
}

variable "app_service_plan_size" {
  description = "The size of the App Service Plan."
  default     = "S1"
  type        = "string"
}
