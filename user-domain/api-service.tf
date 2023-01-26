resource "kubernetes_service_v1" "user_service" {
  metadata {
    name      = "user-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "grpc-service"
      env     = var.environment
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
      target_port = 50051
    }
    type = "ClusterIP"
  }
  depends_on = [
    kubernetes_deployment_v1.user_domain_service
  ]
}

resource "kubernetes_deployment_v1" "user_domain_service" {
  metadata {
    name      = "user-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "grpc-service"
      env     = var.environment
      app     = local.app
      mylabel = var.microservicelabel
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
          name              = "user-service"
          image             = "ghcr.io/sean0427/micro-service-pratice-user-domain:main"
          image_pull_policy = "Always"

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
            container_port = 50051
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_stateful_set_v1.database
  ]
}
