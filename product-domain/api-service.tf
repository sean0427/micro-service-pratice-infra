resource "kubernetes_deployment_v1" "product_domain_service" {
  // TODO

  metadata {
    name = "product-domain-service"
    labels = {
      type = "web_service"
      env  = var.environment
      app  = "micro_service_pratice_product"
      mylabel = local.microservicelabel
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "micro_service_pratice_product"
      }
    }
    
    template {
      metadata {
        labels = {
          k8s-app = "micro_service_pratice_product"
          mylabel = local.microservicelabel
        }

        annotations = {}
      }
      spec {
        container {
          name  = "product-service"
          image = "sean0427/micro-service-pratice-product-domain:main"
        }
      } 
    }
  }
}
