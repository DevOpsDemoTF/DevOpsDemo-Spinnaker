variable "name" {}
variable "template" {}
variable "vars" {
  type = map(string)
}
variable "storage" {
  type = object({resource_group=string,storage_account=string,container=string})
}