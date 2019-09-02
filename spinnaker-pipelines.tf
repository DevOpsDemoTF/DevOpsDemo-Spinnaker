locals {
  pipeline_storage = {
    resource_group  = azurerm_resource_group.spinnaker.name
    storage_account = azurerm_storage_account.spinnaker.name
    container       = azurerm_storage_container.spinnaker.name
  }
}

module "pipeline_deploy_to_dev" {
  source = "./pipeline"

  name = "deployToDEV"
  storage = local.pipeline_storage
  template = file("${path.module}/templates/pipeline_deploy_to_dev.json")
  vars = {
    k8s_context     = var.environments[0].context
    docker_account  = lower(var.environments[0].name)
    docker_registry = azurerm_container_registry.registry[0].login_server
  }
}

resource "kubernetes_secret" "copy_image_secrets" {
  metadata {
    name      = "copy-image-secrets"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {for e in var.environments: lower(e.name) => "${azuread_service_principal.spinnaker.application_id}:${azuread_service_principal_password.spinnaker.value}"}
}