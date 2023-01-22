variable "environment" {
  type    = string
  default = "local"
}

variable "namespace_name" {
  type    = string
  default = "test"
}

variable "resource_group" {
  type    = string
  default = "test"
}

locals {
  microservicelabel = "microservicelabel"
  app               = local.app
}

variable "expose_label" {
  type    = string
  default = "general"
}