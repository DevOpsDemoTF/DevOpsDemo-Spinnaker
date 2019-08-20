resource "azuread_application" "spinnaker" {
  name = local.CName
}

resource "azuread_service_principal" "spinnaker" {
  application_id = azuread_application.spinnaker.application_id
}

resource "random_string" "spinnaker_sp_password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "spinnaker" {
  end_date             = "2299-12-30T23:00:00Z"
  service_principal_id = azuread_service_principal.spinnaker.id
  value                = random_string.spinnaker_sp_password.result
}
