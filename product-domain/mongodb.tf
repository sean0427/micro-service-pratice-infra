resource "kubernetes_config_map_v1" "mongodb_config" {
  metadata {
    name      = "mongodb-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    MONGODB_DB      = var.mongodb_database
    MONGODB_ADDRESS = "${kubernetes_service_v1.mongodb_service.metadata[0].name}.${kubernetes_namespace_v1.namespace.metadata[0].name}"
    MONGODB_PORT    = kubernetes_service_v1.mongodb_service.spec[0].port[0].target_port
  }
}

resource "kubernetes_secret_v1" "mongodb_secret" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    MONGO_APP_DB_USERNAME = "app_admin_user"
    MONGO_APP_DB_PASSWORD = file("${path.module}/../.secret/mongodb_app_pw")
  }
}

resource "kubernetes_config_map_v1" "mongo_db_root_init_config" {
  metadata {
    name      = "mongodb-root-init-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    MONGO_INITDB_DATABASE           = var.mongodb_database
    MONGO_INITDB_ROOT_USERNAME      = "admin"
    MONGO_INITDB_ROOT_PASSWORD_FILE = "/run/secrets/mongo-root/MONGO_INITDB_ROOT_PASSWORD"
  }
}

resource "kubernetes_secret_v1" "mongodb_root_secret" {
  metadata {
    name      = "mongodb-root-secret"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    MONGO_INITDB_ROOT_PASSWORD = file("${path.module}/../.secret/mongodb_pw")
  }
}

# might not a good way for implement
resource "kubernetes_config_map_v1" "mongodb_db_init_config" {
  metadata {
    name      = "mongodb-database-init-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    "0-mongo-init.js" : file("${path.module}/mongo-script/0-mongo-init.js")
    "11-mongo-init-db.js" : file("${path.module}/mongo-script/11-mongo-init-db.js")
  }
}

resource "kubernetes_service_v1" "mongodb_service" {
  metadata {
    name      = "product-domain-database-mongodb-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "database"
      env     = var.environment
      mylabel = var.microservicelabel
      app     = local.app
    }

  }

  spec {
    selector = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "mongodb"
      env     = var.environment
    }
    cluster_ip = "None"

    port {
      port        = 5000
      target_port = 5000
    }
  }
}

resource "kubernetes_stateful_set_v1" "database" {
  metadata {
    name      = "product-domain-database-mongodb"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "mongodb"
      env     = var.environment
    }
  }

  spec {
    service_name           = "mongodb"
    replicas               = 1
    revision_history_limit = 2

    selector {
      match_labels = {
        app     = local.app
        mylabel = var.microservicelabel
        type    = "mongodb"
        env     = var.environment
      }
    }
    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = var.microservicelabel
          type    = "mongodb"
          env     = var.environment
        }

        annotations = {}
      }
      spec {

        container {
          name              = "product-domain-database-mongodb"
          image             = "mongo:6-focal"
          image_pull_policy = "IfNotPresent"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.mongo_db_root_init_config.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.mongodb_db_init_config.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.mongodb_secret.metadata[0].name
            }
          }

          volume_mount {
            name       = "db-init-volume"
            mount_path = "/docker-entrypoint-initdb.d/"
            read_only  = true
          }

          volume_mount {
            name       = "mongo-secret-root-user"
            mount_path = "/run/secrets/mongo-root"
            read_only  = true
          }

          command = [
            "mongod",
            "--bind_ip",
            "0.0.0.0",
            "--port",
            "5000"
          ]


          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = var.mongodb_cpu.limits
              memory = var.mongodb_memory.limits
            }

            requests = {
              cpu    = var.mongodb_cpu.requests
              memory = var.mongodb_memory.requests
            }
          }


          volume_mount {
            name       = "product-mongodb-volume-claim"
            mount_path = "/data/db"
          }

        }
        volume {
          name = "db-init-volume"
          config_map {
            name = kubernetes_config_map_v1.mongodb_db_init_config.metadata[0].name
          }
        }
        volume {
          name = "mongo-secret-root-user"
          secret {
            secret_name = kubernetes_secret_v1.mongodb_root_secret.metadata[0].name
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

    volume_claim_template {
      metadata {
        name      = "product-mongodb-volume-claim"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
      }
      spec {
        access_modes       = ["ReadWriteMany"]
        storage_class_name = "local"
        resources {
          requests = {
            storage = "500Mi"
          }
        }
      }
    }
  }
}
