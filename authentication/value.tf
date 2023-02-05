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
  app               = "auth-server"
}

variable "microservicelabel" {
  type    = string
  default = "microservicelabel"

}

variable "redis_cpu" {
  type = object({
    limits   = string
    requests = string
  })
  default = {
    limits   = "10m"
    requests = "10m"
  }
}

variable "redis_memory" {
  type = object({
    limits   = string
    requests = string
  })
  default = {
    limits   = "100Mi"
    requests = "100Mi"
  }
}

variable "expose_label" {
  type    = string
  default = "general"
}

variable "user_domain_path" {
  type = string
}