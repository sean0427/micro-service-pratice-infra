resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = local.microservicelabel
    }

    # TODO: create on general config
    name = "micro-service-practice-user"
  }
}