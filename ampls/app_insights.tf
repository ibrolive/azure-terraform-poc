# ---------------------------------------------------------------------------
# Application Insights
# Linked to the Log Analytics Workspace (workspace-based mode).
# Public ingestion and query are both disabled so that all telemetry must
# travel via the AMPLS private endpoint.
# ---------------------------------------------------------------------------
resource "azurerm_application_insights" "ampls" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.ampls.location
  resource_group_name = azurerm_resource_group.ampls.name
  workspace_id        = azurerm_log_analytics_workspace.ampls.id
  application_type    = var.app_insights_application_type

  # Disable all public-network access – ingestion and query must come through
  # the AMPLS private endpoint only.
  internet_ingestion_enabled = false
  internet_query_enabled     = false

  tags = var.tags
}
