resource "kubernetes_persistent_volume_v1" "storage" {
  metadata {
    name = "${var.name_prefix}-kube-general-volume"
    labels = {
      env            = var.environment
      resource_group = var.resource_group
    }
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    storage_class_name = "local"
    access_modes       = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/var/opt/kube-data"
      }
    }
  }
}
