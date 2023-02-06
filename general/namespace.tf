resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    annotations = {
    }

    labels = {
      mylabel = var.microservicelabel
    }

    name = var.namespace_name
  }
}