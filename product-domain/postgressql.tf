resource "kubernetes_config_map_v1" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    POSTGRES_DB = "test"
    POSTGRES_USER = "admin"
  }
}

resource "kubernetes_secret_v1" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = file("${path.module}/.secret/postgres_pw")
  }
}

resource "kubernetes_stateful_set_v1" "database" {
  metadata {
    name = "product-domain-database-postgresql"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type = "postgresql"
      env  = var.environment
      app  = "micro_service_pratice_product"
    }
  }

  spec {
    service_name           = "postgresql"
    replicas               = 1
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
          image             = "postgres:15-alpine"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.postgres_secret.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.postgres_config.metadata[0].name
            }
          }

          port {
            container_port = 5432
          }

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
