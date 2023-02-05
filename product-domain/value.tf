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
  app = "product-domain"
}

variable "microservicelabel" {
  type    = string
  default = "microservicelabel"
}
variable "expose_label" {
  type    = string
  default = "general"
}


variable "mongodb_cpu" {
  type = object({
    limits   = string
    requests = string
  })
  default = {
    limits   = "1000m"
    requests = "100m"
  }
}

variable "mongodb_memory" {
  type = object({
    limits   = string
    requests = string
  })
  default = {
    limits   = "1000Mi"
    requests = "100Mi"
  }
}

variable "mongodb_database" {
  type    = string
  default = "product-domain"
}