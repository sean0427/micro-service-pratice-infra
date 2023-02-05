resource "kubernetes_service_v1" "product_service" {
  metadata {
    name      = "product-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "restful-api-service"
      env     = var.environment
      expose  = var.expose_label
    }

  }
  spec {
    selector = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "restful-api-service"
      env     = var.environment
    }

    port {
      port        = 80
      target_port = 8080
    }
    type = "ClusterIP"
  }
}


# resource "kubernetes_service_v1" "product_service_outside_lb" {
#   metadata {
#     name      = "product-domain-service-lb"
#     namespace = kubernetes_namespace_v1.namespace.metadata[0].name
#     labels = {
#       app     = local.app
#       mylabel = var.microservicelabel
#       type    = "restful-api-service"
#       env     = var.environment
#       expose  = var.expose_label
#     }

#   }
#   spec {
#     selector = {
#       app     = local.app
#       mylabel = var.microservicelabel
#       type    = "restful-api-service"
#       env     = var.environment
#     }

#     port {
#       port        = 3000
#       target_port = 3000
#       node_port = 30000
#     }
#     type = "LoadBalancer"
#   }
# }

resource "kubernetes_deployment_v1" "product_domain_service" {
  metadata {
    name      = "product-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "restful-api-service"
      env     = var.environment
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = local.app
        mylabel = var.microservicelabel
        type    = "restful-api-service"
        env     = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = var.microservicelabel
          type    = "restful-api-service"
          env     = var.environment
        }

        annotations = {}
      }
      spec {
        container {
          name              = "product-service"
          image             = "product-domain:latest"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.mongodb_secret.metadata[0].name
            }
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.mongodb_config.metadata[0].name
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
    kubernetes_service_v1.mongodb_service
  ]
}
