provider "azurerm" {
  version = "~>1.31.0"
}

provider "azuread" {
  version = "~>0.3"
}

provider "kubernetes" {
  version = "~>1.8"
  host    = var.k8s_host

  client_certificate     = base64decode(var.k8s_client_certificate)
  client_key             = base64decode(var.k8s_client_key)
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

provider "helm" {
  version         = "~>0.10"
  namespace       = var.tiller_namespace
  service_account = var.tiller_name

  kubernetes {
    host = var.k8s_host

    client_certificate     = base64decode(var.k8s_client_certificate)
    client_key             = base64decode(var.k8s_client_key)
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  }
}

provider "random" {
  version = "~>2.2"
}

provider "template" {
  version = "~>2.1"
}
