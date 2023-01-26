output "web-serivce-cluster-ip" {
  value = kubernetes_service_v1.user_service.metadata[0].name
}