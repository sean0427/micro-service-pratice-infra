resource "kubernetes_config_map_v1" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    POSTGRES_DB   = "test"
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

# might not a good way for implement
resource "kubernetes_config_map_v1" "postgres_db_init_config" {
  metadata {
    name      = "postgres-database-init-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    "init-database.sh" : file("${path.module}/schema/init-database.sh")
    "ddl_11-user.sql" : file("${path.module}/schema/ddl/11-user.sql")
    "dml_12-mockdata_sql" : file("${path.module}/schema/dml/11-mockdata.sql")
  }
}

resource "kubernetes_service_v1" "postgres_service" {
  metadata {
    name      = "user-domain-database-postgresql-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "postgresql"
      env     = var.environment
      mylabel = local.microservicelabel
      app     = "micro-service-pratice-user"
    }

  }

  spec {
    selector = {
      app     = "micro-service-pratice-user"
      mylabel = local.microservicelabel
      type    = "postgresql"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_stateful_set_v1" "database" {
  metadata {
    name      = "user-domain-database-postgresql"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "postgresql"
      env     = var.environment
      mylabel = local.microservicelabel
      app     = "micro-service-pratice-user"
    }
  }

  spec {
    service_name           = "postgresql"
    replicas               = 1
    revision_history_limit = 2

    selector {
      match_labels = {
        app     = "micro-service-pratice-user"
        mylabel = local.microservicelabel
        type    = "postgresql"
      }
    }
    template {
      metadata {
        labels = {
          app     = "micro-service-pratice-user"
          mylabel = local.microservicelabel
          type    = "postgresql"
        }

        annotations = {}
      }
      spec {

        container {
          name              = "user-domain-database-postgresql"
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

          volume_mount {
            name       = "db-init-volume"
            mount_path = "/docker-entrypoint-initdb.d/"
            read_only  = true
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
        volume {
          name = "db-init-volume"

          config_map {
            name = kubernetes_config_map_v1.postgres_db_init_config.metadata[0].name
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
