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
  app = "company-domain"
}

variable "microservicelabel" {
  type    = string
  default = "microservicelabel"
}

variable "expose_label" {
  type    = string
  default = "general"
}

variable "outbox_path" {
  type    = string
  default = "none"
}
