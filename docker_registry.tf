resource "azurerm_container_registry" "registry" {
  count               = length(var.environments)

  name                = "${local.cname}${var.environments[count.index].name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spinnaker.name
  admin_enabled       = false
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "spinnaker_acr" {
  count = length(var.environments)

  principal_id         = azuread_service_principal.spinnaker.object_id
  scope                = azurerm_container_registry.registry[count.index].id
  role_definition_name = "AcrPush"
}

resource "azurerm_role_assignment" "kubernetes_acr" {
  count = length(var.environments)

  principal_id         = var.environments[count.index].principal
  scope                = azurerm_container_registry.registry[count.index].id
  role_definition_name = "AcrPull"
}

resource "kubernetes_secret" "docker_registries" {
  metadata {
    name      = "docker-registries"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {for e in var.environments:lower(e.name) => azuread_service_principal_password.spinnaker.value}
}
