data "template_file" "deploy_to_dev" {
  template = file("${path.module}/templates/pipeline_deploy_to_dev.json")

  vars = {
    k8s_context     = var.environments[0].context
    docker_account  = lower(var.environments[0].name)
    docker_registry = azurerm_container_registry.registry[0].login_server
  }
}

resource "local_file" "pipeline_deploy_to_dev" {
  filename          = "${path.module}/.generated/pipeline_deploy_to_dev.json"
  sensitive_content = data.template_file.deploy_to_dev.rendered
}

resource "azurerm_storage_blob" "pipeline_deploy_to_dev" {
  name                   = "pipeline-templates/deploytodev/pipeline-template-metadata.json"
  resource_group_name    = azurerm_resource_group.spinnaker.name
  storage_account_name   = azurerm_storage_account.spinnaker.name
  storage_container_name = azurerm_storage_container.spinnaker.name

  type         = "block"
  content_type = "application/json"
  source       = local_file.pipeline_deploy_to_dev.filename

  depends_on = [local_file.pipeline_deploy_to_dev]
}

resource "kubernetes_secret" "copy_image_secrets" {
  metadata {
    name = "copy-image-secrets"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = { for e in var.environments: lower(e.name) => "${azuread_service_principal.spinnaker.application_id}:${azuread_service_principal_password.spinnaker.value}" }
}