# ---------------------------------------------------------------------------
# Azure Policy – Governance Controls
#
# Two built-in policy definitions are assigned at the resource-group scope:
#
#   1. Deny public network access on Log Analytics workspaces
#      Built-in ID: 8cf596f7-3b0b-4b64-8606-8b2c5b2a93c1
#
#   2. Deny public network access on Application Insights components
#      Built-in ID: 1bc2ad8e-2d61-4dbd-b318-a69f4edda827
#
# Assignments are scoped to the resource group so that they govern only the
# AMPLS-related resources managed by this module.
# ---------------------------------------------------------------------------

data "azurerm_policy_definition" "deny_law_public_access" {
  display_name = "Log Analytics workspaces should block log ingestion and querying from public networks"
}

data "azurerm_policy_definition" "deny_appi_public_access" {
  display_name = "Application Insights components should block log ingestion and querying from public networks"
}

resource "azurerm_resource_group_policy_assignment" "deny_law_public_access" {
  name                 = "deny-law-public-access"
  resource_group_id    = azurerm_resource_group.ampls.id
  policy_definition_id = data.azurerm_policy_definition.deny_law_public_access.id
  description          = "Denies public network access to Log Analytics workspaces to enforce AMPLS-only traffic."
  display_name         = "Deny public network access – Log Analytics"

  enforce = true
}

resource "azurerm_resource_group_policy_assignment" "deny_appi_public_access" {
  name                 = "deny-appi-public-access"
  resource_group_id    = azurerm_resource_group.ampls.id
  policy_definition_id = data.azurerm_policy_definition.deny_appi_public_access.id
  description          = "Denies public network access to Application Insights to enforce AMPLS-only traffic."
  display_name         = "Deny public network access – Application Insights"

  enforce = true
}
