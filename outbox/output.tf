output "web-serivce-cluster-ip" {
  value = "${kubernetes_service_v1.outbox_service.metadata[0].name}.${var.namespace_name}:${kubernetes_service_v1.outbox_service.spec[0].port[0].port}/message/push"
}