resource "kubernetes_service_v1" "service_lb" {
  metadata {
    name      = "product-domain-database-postgresql-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      type    = "web_service"
      env     = var.environment
      app     = "micro_service_pratice_product"
      mylabel = local.microservicelabel
    }

  }
  spec {
    selector = {
      app     = "micro_service_pratice_product"
      mylabel = local.microservicelabel
      type    = "web_service"
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
      type    = "web_service"
      env     = var.environment
      app     = "micro_service_pratice_product"
      mylabel = local.microservicelabel
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "micro_service_pratice_product"
        mylabel = local.microservicelabel
        type    = "web_service"
      }
    }

    template {
      metadata {
        labels = {
          app     = "micro_service_pratice_product"
          mylabel = local.microservicelabel
          type    = "web_service"
        }

        annotations = {}
      }
      spec {
        container {
          name  = "product-service"
          image = "ghcr.io/sean0427/micro-service-pratice-product-domain:main"

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
