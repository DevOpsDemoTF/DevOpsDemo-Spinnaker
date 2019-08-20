resource "azurerm_resource_group" "spinnaker" {
  name     = local.CName
  location = var.location
}

resource "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

resource "helm_release" "spinnaker" {
  name          = "spinnaker"
  chart         = "stable/spinnaker"
  namespace     = kubernetes_namespace.spinnaker.metadata.0.name
  force_update  = "true"
  recreate_pods = "true"

  timeout = 600

  values = [data.template_file.spinnaker_values.rendered, data.template_file.docker_registry.rendered,
    "dockerRegistryAccountSecret: ${kubernetes_secret.docker_registries.metadata.0.name}"]
}

resource "kubernetes_secret" "docker_registries" {
  metadata {
    name = "docker-registries"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {
    "${var.environments.0}" = azuread_service_principal_password.spinnaker.value
  }
}

data "template_file" "docker_registry" {
  template = file("${path.module}/templates/registry.yaml")
  vars     = {
    name    = var.environments[0]
    address = azurerm_container_registry.registry.login_server
    username = azuread_service_principal.spinnaker.object_id
  }
}

data "template_file" "spinnaker_values" {
  template = file("${path.module}/templates/values.yaml")
  vars     = {
    storage_account = azurerm_storage_account.spinnaker.name
    storage_access_key = azurerm_storage_account.spinnaker.primary_access_key
    storage_container_name = azurerm_storage_container.spinnaker.name
  }
}

resource "azurerm_storage_account" "spinnaker" {
  name = local.cname
  resource_group_name = azurerm_resource_group.spinnaker.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "spinnaker" {
  name = "spinnaker"
  storage_account_name = azurerm_storage_account.spinnaker.name
  container_access_type = "private"
}
