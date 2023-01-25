resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = var.microservicelabel
    }

    name = var.namespace_name
  }
}