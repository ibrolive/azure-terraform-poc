# ---------------------------------------------------------------------------
# Log Analytics Workspace
# Public ingestion and query are both disabled so that all traffic must
# travel via the AMPLS private endpoint.
# ---------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "ampls" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.ampls.location
  resource_group_name = azurerm_resource_group.ampls.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  # Disable all public-network access – ingestion and query must come through
  # the AMPLS private endpoint only.
  internet_ingestion_enabled = false
  internet_query_enabled     = false

  tags = var.tags
}
