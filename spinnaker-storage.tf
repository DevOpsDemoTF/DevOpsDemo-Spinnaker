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
