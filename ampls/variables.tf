variable "location" {
  description = "Azure region where all resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group for all AMPLS resources."
  type        = string
  default     = "rg-ampls-prod"
}

variable "environment" {
  description = "Deployment environment tag (e.g. prod, staging)."
  type        = string
  default     = "prod"
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
  default     = "vnet-ampls-prod"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet used to host the private endpoint."
  type        = string
  default     = "snet-privateendpoints"
}

variable "subnet_address_prefixes" {
  description = "Address prefix for the private-endpoint subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
  default     = "law-ampls-prod"
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics Workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Data retention period (days) for the Log Analytics Workspace."
  type        = number
  default     = 90
}

variable "app_insights_name" {
  description = "Name of the Application Insights component."
  type        = string
  default     = "appi-ampls-prod"
}

variable "app_insights_application_type" {
  description = "Application type for Application Insights."
  type        = string
  default     = "web"
}

variable "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope."
  type        = string
  default     = "ampls-prod"
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint for AMPLS."
  type        = string
  default     = "pe-ampls-prod"
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default = {
    environment = "prod"
    managed_by  = "terraform"
    workload    = "azure-monitor-private-link"
  }
}
