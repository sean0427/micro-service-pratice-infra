resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = local.microservicelabel
    }

    name = "micro-service-authorization"
  }
}