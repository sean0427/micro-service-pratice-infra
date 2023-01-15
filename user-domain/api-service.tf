resource "kubernetes_service_v1" "service_lb" {
  metadata {
    name      = "user-domain-database-postgresql-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "web-service"
      env     = var.environment
      app     = "micro-service-pratice-user"
      mylabel = local.microservicelabel
    }

  }
  spec {
    selector = {
      app     = "micro-service-pratice-user"
      mylabel = local.microservicelabel
      type    = "web-service"
    }

    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment_v1" "user_domain_service" {
  metadata {
    name      = "user-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "web-service"
      env     = var.environment
      app     = "micro-service-pratice-user"
      mylabel = local.microservicelabel
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "micro-service-pratice-user"
        mylabel = local.microservicelabel
        type    = "web-service"
      }
    }

    template {
      metadata {
        labels = {
          app     = "micro-service-pratice-user"
          mylabel = local.microservicelabel
          type    = "web-service"
        }

        annotations = {}
      }
      spec {
        container {
          name  = "user-service"
          image = "ghcr.io/sean0427/micro-service-pratice-user-domain:main"

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
            container_port = 8080
          }
        }
      }
    }
  }
 
  depends_on = [
    kubernetes_stateful_set_v1.database
  ]
}
