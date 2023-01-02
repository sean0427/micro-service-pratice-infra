// TODO
resource "kubernetes_stateful_set_v1" "database" {
  metadata {
    name = "product-domain-database-postgresql"
    labels = {
      type = "postgresql"
      env  = var.environment
      app  = "micro_service_pratice_product"
    }
  }

  spec {
    service_name = "postgresql"
    replicas = 1
    revision_history_limit = 2

    selector {
      match_labels = {
        k8s-app = "postgresql"
      }
    }   
    template {
      metadata {
        labels = {
          k8s-app = "postgresql"
          mylabel = local.microservicelabel
        }

        annotations = {}
      }
      spec {

        container {
          name              = "product-domain-database-postgresql"
          image             = "postgresql:15-alpine"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = "10m"
              memory = "10Mi"
            }

            requests = {
              cpu    = "10m"
              memory = "10Mi"
            }
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }  
  }
}


variable "pg_user" {
  type = string
  // TODO
  default = "admin"
}

variable "pg_password" {
  type = string
  // TODO
  default = "eifaji;oewfnjio;we"
}