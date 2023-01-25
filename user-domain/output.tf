output "web-serivce-cluster-ip" {
  value = kubernetes_service_v1.user_service.spec[0].cluster_ip
}