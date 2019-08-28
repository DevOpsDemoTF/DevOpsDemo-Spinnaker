variable "prefix" {
  default = "DevOpsDemo"
}

variable "location" {
  default = "East US"
}

variable "environments" {
  type = list(object({
    name=string,
    principal=string,
    kube_conf=string,
    context=string,
  }))
}

variable "domain" {}
