output "resource_group_name" {
  description = "Name of the resource group containing all AMPLS resources."
  value       = azurerm_resource_group.ampls.name
}

output "resource_group_id" {
  description = "Resource ID of the resource group."
  value       = azurerm_resource_group.ampls.id
}

output "virtual_network_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.ampls.id
}

output "subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  value       = azurerm_subnet.private_endpoints.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.ampls.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.ampls.name
}

output "application_insights_id" {
  description = "Resource ID of the Application Insights component."
  value       = azurerm_application_insights.ampls.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for the Application Insights component."
  value       = azurerm_application_insights.ampls.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for the Application Insights component."
  value       = azurerm_application_insights.ampls.connection_string
  sensitive   = true
}

output "ampls_id" {
  description = "Resource ID of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.ampls.id
}

output "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.ampls.name
}

output "private_endpoint_id" {
  description = "Resource ID of the AMPLS private endpoint."
  value       = azurerm_private_endpoint.ampls.id
}

output "private_endpoint_ip_address" {
  description = "Private IP address assigned to the AMPLS private endpoint NIC."
  value       = azurerm_private_endpoint.ampls.private_service_connection[0].private_ip_address
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to their resource IDs."
  value       = { for k, v in azurerm_private_dns_zone.ampls : k => v.id }
}
