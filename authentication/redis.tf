resource "kubernetes_service_v1" "redis_service" {
  metadata {
    name      = "authauthentication-redis-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "redis"
      env     = var.environment
    }

  }

  spec {
    selector = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "redis"
      env     = var.environment
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}

resource "random_password" "password" {
  length           = 50
  special          = true
  override_special = "_%@"
}

resource "kubernetes_secret_v1" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    REDIS_PASSWORD = random_password.password.result
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "authentication-serivce-redis"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "redis"
      env     = var.environment
    }
  }
  spec {
    service_name           = "redis"
    replicas               = 1
    revision_history_limit = 1

    selector {
      match_labels = {
        app     = local.app
        mylabel = var.microservicelabel
        type    = "redis"
        env     = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = var.microservicelabel
          type    = "redis"
          env     = var.environment
        }

        annotations = {}
      }


      spec {

        container {
          name              = "authentication-serivce-redis"
          image             = "redis:7.0-alpine"
          image_pull_policy = "IfNotPresent"
          # TODO
          # command = "--requirepass $${REDIS_PASSWORD}"


          env_from {
            secret_ref {
              name = kubernetes_secret_v1.redis_secret.metadata[0].name
            }
          }

          port {
            container_port = 6379
          }

          resources {
            limits = {
              cpu    = var.redis_memory.limits
              memory = var.redis_memory.limits
            }
            requests = {
              cpu    = var.redis_cpu.requests
              memory = var.redis_memory.requests
            }
          }

          // might need to consistance mount for state recovery
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