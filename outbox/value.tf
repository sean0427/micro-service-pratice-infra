variable "environment" {
  type    = string
  default = "local"
}

variable "resource_group" {
  type    = string
  default = "test"
}


variable "namespace_name" {
  type    = string
  default = "test"
}

locals {
  app = "outbox-service"
}

variable "microservicelabel" {
  type    = string
  default = "microservicelabel"
}

variable "expose_label" {
  type    = string
  default = "general"
}


variable "kafaka_path" {
  type    = string
  default = "general"
}