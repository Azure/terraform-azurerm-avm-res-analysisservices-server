resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.name # calling code must supply the name
  tags     = var.tags
}

resource "random_string" "azurerm_analysis_services_server_name" {
  length  = 25
  upper   = false
  numeric = false
  special = false
}

resource "azurerm_analysis_services_server" "server" {
  name                      = random_string.azurerm_analysis_services_server_name.result
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  sku                       = var.sku
  backup_blob_container_uri = var.backup_blob_container_uri
  power_bi_service_enabled = var.power_bi_service_enabled
  admin_users              = var.admin_users

  ipv4_firewall_rule {
    name        = "AllowFromAll"
    range_start = "0.0.0.0"
    range_end   = "255.255.255.255"
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_resource_group.rg.id 
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_resource_group.rg.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
