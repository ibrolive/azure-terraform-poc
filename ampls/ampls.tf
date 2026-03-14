# ---------------------------------------------------------------------------
# Azure Monitor Private Link Scope (AMPLS)
# Creates the private connectivity boundary that wraps the Log Analytics
# workspace and Application Insights component.
#
# ingestion_access_mode  = "PrivateOnly"  – only private-endpoint traffic
# query_access_mode      = "PrivateOnly"  – query API also private-only
# ---------------------------------------------------------------------------
resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = var.ampls_name
  resource_group_name = azurerm_resource_group.ampls.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Scoped Services
# Associates the Log Analytics workspace and Application Insights component
# with the AMPLS so that their traffic is governed by the private endpoint.
# ---------------------------------------------------------------------------
resource "azurerm_monitor_private_link_scoped_service" "law" {
  name                = "scoped-law-${var.log_analytics_workspace_name}"
  resource_group_name = azurerm_resource_group.ampls.name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
  linked_resource_id  = azurerm_log_analytics_workspace.ampls.id
}

resource "azurerm_monitor_private_link_scoped_service" "appi" {
  name                = "scoped-appi-${var.app_insights_name}"
  resource_group_name = azurerm_resource_group.ampls.name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
  linked_resource_id  = azurerm_application_insights.ampls.id
}
