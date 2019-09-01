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
  recreate_pods = "true"

  timeout = 1000

  values = [data.template_file.halyard_config.rendered, data.template_file.spinnaker_values.rendered,
    local.registries_config, "dockerRegistryAccountSecret: ${kubernetes_secret.docker_registries.metadata.0.name}",
    data.template_file.k8s_clusters.rendered]
}

data "template_file" "halyard_config" {
  template = file("${path.module}/templates/halyard.yaml")
  vars     = {
    halyard_config     = kubernetes_config_map.halyard_config.metadata.0.name
    halyard_config_key = "halyard.sh"
    azure_tenant       = data.azurerm_client_config.current.tenant_id
    copy_image_context = var.environments[0].context
    copy_image_secrets = kubernetes_secret.copy_image_secrets.metadata.0.name
  }
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
