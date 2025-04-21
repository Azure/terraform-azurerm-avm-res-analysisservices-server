output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "analysis_services_server_name" {
  value = azurerm_analysis_services_server.server.name
}
