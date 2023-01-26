resource "kubernetes_service_v1" "auth_service" {
  metadata {
    name      = "auth-server-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "grpc-service"
      env     = var.environment
      expose  = var.expose_label
    }

  }
  spec {
    selector = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "grpc-service"
      env     = var.environment
    }

    port {
      port        = 80
      target_port = 8080
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment_v1.auth_service
  ]
}

resource "kubernetes_config_map_v1" "auth_serivce_config" {
  metadata {
    name      = "auth-server-config-map"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }


  data = {
    USER_AUTHGRPC_ADDR  = var.user_domain_path
    REDIS_ADDRESS       = kubernetes_service_v1.redis_service.metadata[0].name
    JWT_SECRET_KEY_FILE = "/etc/secret/jwt/JWT_KEY"
  }
}

resource "kubernetes_deployment_v1" "auth_service" {
  metadata {
    name      = "auth-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "grpc-service"
      env     = var.environment
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = local.app
        mylabel = var.microservicelabel
        type    = "grpc-service"
        env     = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = var.microservicelabel
          type    = "grpc-service"
          env     = var.environment
        }

        annotations = {}
      }
      spec {
        container {
          name = "auth-service"
          # TODO: authentication docker
          image             = "auth-domain:latest"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.redis_secret.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.auth_serivce_config.metadata[0].name
            }
          }


          volume_mount {
            name       = "jwt-token-secret"
            mount_path = "/etc/secret/jwt"
            read_only  = true
          }

          port {
            container_port = 8080
          }
        }

        volume {
          name = "jwt-token-secret"
          secret {
            secret_name = kubernetes_secret_v1.JWT_SECRET_KEY.metadata[0].name
          }
        }
      }

    }
  }

  depends_on = [
    kubernetes_service_v1.redis_service
  ]
}

