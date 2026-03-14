# ---------------------------------------------------------------------------
# Private DNS Zones required by Azure Monitor Private Link
#
# All five zones are mandatory for full AMPLS coverage:
#   - privatelink.monitor.azure.com          (Azure Monitor REST APIs)
#   - privatelink.oms.opinsights.azure.com   (OMS agent ingestion)
#   - privatelink.ods.opinsights.azure.com   (ODS agent ingestion)
#   - privatelink.agentsvc.azure-automation.net (agent heartbeat / config)
#   - privatelink.blob.core.windows.net      (agent storage artefacts)
# ---------------------------------------------------------------------------
locals {
  ampls_private_dns_zones = [
    "privatelink.monitor.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.blob.core.windows.net",
  ]
}

resource "azurerm_private_dns_zone" "ampls" {
  for_each = toset(local.ampls_private_dns_zones)

  name                = each.key
  resource_group_name = azurerm_resource_group.ampls.name
  tags                = var.tags
}

# Link every DNS zone to the VNet so that VMs / workloads inside the VNet
# resolve Azure Monitor FQDNs to private IP addresses.
resource "azurerm_private_dns_zone_virtual_network_link" "ampls" {
  for_each = toset(local.ampls_private_dns_zones)

  name                  = "link-${replace(each.key, ".", "-")}"
  resource_group_name   = azurerm_resource_group.ampls.name
  private_dns_zone_name = azurerm_private_dns_zone.ampls[each.key].name
  virtual_network_id    = azurerm_virtual_network.ampls.id
  registration_enabled  = false
  tags                  = var.tags
}

# ---------------------------------------------------------------------------
# Private Endpoint for AMPLS
# One private endpoint per region is sufficient; it covers all resources
# linked to the scope.
# ---------------------------------------------------------------------------
resource "azurerm_private_endpoint" "ampls" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.ampls.location
  resource_group_name = azurerm_resource_group.ampls.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.ampls_name}"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  # Attach all five DNS zone groups so the private endpoint automatically
  # populates A-records in every required private DNS zone.
  private_dns_zone_group {
    name = "ampls-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.ampls["privatelink.monitor.azure.com"].id,
      azurerm_private_dns_zone.ampls["privatelink.oms.opinsights.azure.com"].id,
      azurerm_private_dns_zone.ampls["privatelink.ods.opinsights.azure.com"].id,
      azurerm_private_dns_zone.ampls["privatelink.agentsvc.azure-automation.net"].id,
      azurerm_private_dns_zone.ampls["privatelink.blob.core.windows.net"].id,
    ]
  }
}
