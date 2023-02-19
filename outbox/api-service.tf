resource "kubernetes_service_v1" "outbox_service" {
  metadata {
    name      = "outbox-service"
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

resource "kubernetes_config_map_v1" "kafaka_config" {
  metadata {
    name      = "kafka-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    "KAFKA_PATH" = var.kafaka_path
  }
}

resource "kubernetes_deployment_v1" "outbox_domain_service" {
  metadata {
    name      = "outbox-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = var.microservicelabel
      type    = "restful-api-service"
      env     = var.environment
    }
  }

  spec {
    replicas = 2
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
          name              = "outbox-service"
          image             = "outbox-service:latest"
          image_pull_policy = "Always"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.kafaka_config.metadata[0].name
            }
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = 8080
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 2
          }

          readiness_probe {
            http_get {
              path   = "/readiness"
              port   = 8080
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 2
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
