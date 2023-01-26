resource "kubernetes_service_v1" "product_service_lb" {
  metadata {
    name      = "product-domain-service-lb"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "web-service"
      env     = var.environment
      expose  = var.expose_label
    }

  }
  spec {
    selector = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "web-service"
      env     = var.environment
    }

    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment_v1" "product_domain_service" {
  // TODO

  metadata {
    name      = "product-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "web-service"
      env     = var.environment
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = local.app
        mylabel = var.microservicelabel
        type    = "web-service"
        env     = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = var.microservicelabel
          type    = "web-service"
          env     = var.environment
        }

        annotations = {}
      }
      spec {
        container {
          name  = "product-service"
          image = "ghcr.io/sean0427/micro-service-product-domain:main"

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
}
