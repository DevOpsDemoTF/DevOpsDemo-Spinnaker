locals {
  id = lower(var.name)
}

data "template_file" "pipeline" {
  template = var.template
  vars = merge({id=local.id, name=var.name}, var.vars)
}

resource "local_file" "pipeline" {
  filename          = "${path.module}/.generated/${local.id}.json"
  sensitive_content = data.template_file.pipeline.rendered
}

resource "azurerm_storage_blob" "pipeline" {
  name                   = "pipeline-templates/${local.id}/pipeline-template-metadata.json"
  resource_group_name    = var.storage.resource_group
  storage_account_name   = var.storage.storage_account
  storage_container_name = var.storage.container

  type         = "block"
  content_type = "application/json"
  source       = local_file.pipeline.filename

  depends_on = [local_file.pipeline]
}

