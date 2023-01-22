resource "kubernetes_service_v1" "auth_ervice_lb" {
  metadata {
    name      = "auth-domain-service-lb"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = local.microservicelabel
      type    = "grpc-service"
      env     = var.environment
      expose  = var.expose_label
    }

  }
  spec {
    selector = {
      app     = local.app
      mylabel = local.microservicelabel
      type    = "grpc-service"
      env     = var.environment
    }

    port {
      port        = 80
      target_port = 50051
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment_v1" "auth_domain_service" {
  metadata {
    name      = "auth-domain-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app     = local.app
      mylabel = local.microservicelabel
      type    = "grpc-service"
      env     = var.environment
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = local.app
        mylabel = local.microservicelabel
        type    = "grpc-service"
        env     = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app     = local.app
          mylabel = local.microservicelabel
          type    = "grpc-service"
          env     = var.environment
        }

        annotations = {}
      }
      spec {
        container {
          name              = "auth-service"
          # TODO: authentication docker
          image             = "auth-domain:latest"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.redis_secret.metadata[0].name
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

