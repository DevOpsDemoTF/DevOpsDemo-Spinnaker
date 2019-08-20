resource "azurerm_container_registry" "registry" {
  name                = local.cname
  location            = var.location
  resource_group_name = azurerm_resource_group.spinnaker.name
  admin_enabled       = false
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "spinnaker_acr" {
  principal_id = azuread_service_principal.spinnaker.object_id
  scope = azurerm_container_registry.registry.id
  role_definition_name = "AcrPush"
}