locals {
  reply_url = "https://${var.domain}/gate/login"
}

resource "azuread_application" "oauth" {
  name                       = local.CName
  type                       = "webapp/api"
  oauth2_allow_implicit_flow = true
  available_to_other_tenants = false
  homepage                   = "https://${var.domain}/"
  reply_urls                 = [local.reply_url]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "azuread_application_password" "oauth" {
  end_date              = "2299-12-30T23:00:00Z"
  application_object_id = azuread_application.oauth.object_id
  value                 = random_string.client_secret.result
}

data "azurerm_client_config" "current" {}

resource "random_string" "client_secret" {
  length  = 32
  special = true
}

data "template_file" "halyard_sh" {
  template = file("${path.module}/templates/halyard.sh")
  vars = {
    client_id     = azuread_application.oauth.application_id
    client_secret = azuread_application_password.oauth.value
    callback_url  = local.reply_url
  }
}

resource "kubernetes_config_map" "halyard_config" {
  metadata {
    name = "halyard-config-local"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {
    "halyard.sh" = data.template_file.halyard_sh.rendered
  }
}

# FIXME use secret instead of passing via script
resource "kubernetes_secret" "gate_secrets" {
  metadata {
    name      = "gate-secrets-local"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {
    azureTenantId     = data.azurerm_client_config.current.tenant_id
    azureClientId     = azuread_application.oauth.application_id
    azureClientSecret = azuread_application_password.oauth.value
  }
}
