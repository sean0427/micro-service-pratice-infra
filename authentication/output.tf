output "web-serivce-cluster-ip" {
  # value = "${kubernetes_service_v1.auth_service.spec[0].cluster_ip}:${kuber}"

  value = kubernetes_service_v1.auth_service.spec[0].ports.port
}