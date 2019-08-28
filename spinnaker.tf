resource "azurerm_resource_group" "spinnaker" {
  name     = local.CName
  location = var.location
}

resource "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

locals {
  registries_config = join("", concat(
  [file("${path.module}/templates/registries.yaml")], data.template_file.docker_registry.*.rendered))
}

resource "helm_release" "spinnaker" {
  name          = "spinnaker"
  chart         = "stable/spinnaker"
  namespace     = kubernetes_namespace.spinnaker.metadata.0.name
  force_update  = "true"

  timeout = 600

  values = [file("${path.module}/templates/halyard.yaml"), data.template_file.spinnaker_values.rendered,
    local.registries_config, "dockerRegistryAccountSecret: ${kubernetes_secret.docker_registries.metadata.0.name}",
    data.template_file.k8s_clusters.rendered
  ]
}

resource "kubernetes_secret" "docker_registries" {
  metadata {
    name      = "docker-registries"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {for e in var.environments:lower(e.name) => azuread_service_principal_password.spinnaker.value}
}

data "template_file" "docker_registry" {
  count = length(var.environments)

  template = file("${path.module}/templates/registry.yaml")
  vars     = {
    name     = lower(var.environments[count.index].name)
    address  = azurerm_container_registry.registry[count.index].login_server
    username = azuread_service_principal.spinnaker.application_id
  }
}

data "template_file" "spinnaker_values" {
  template = file("${path.module}/templates/values.yaml")
  vars     = {
    storage_account        = azurerm_storage_account.spinnaker.name
    storage_access_key     = azurerm_storage_account.spinnaker.primary_access_key
    storage_container_name = azurerm_storage_container.spinnaker.name
  }
}

resource "azurerm_storage_account" "spinnaker" {
  name                     = local.cname
  resource_group_name      = azurerm_resource_group.spinnaker.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "spinnaker" {
  name                  = "spinnaker"
  storage_account_name  = azurerm_storage_account.spinnaker.name
  container_access_type = "container"
}
