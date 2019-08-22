variable "prefix" {
  default = "DevOpsDemo"
}

variable "location" {
  default = "East US"
}

variable "environments" {
  default = ["DEV"]
}

variable "k8s_client_key" {}
variable "k8s_client_certificate" {}
variable "k8s_cluster_ca_certificate" {}
variable "k8s_config" {}
variable "k8s_host" {}
variable "k8s_fqdn" {}
variable "k8s_service_principal" {}
variable "tiller_namespace" {}
variable "tiller_name" {}
