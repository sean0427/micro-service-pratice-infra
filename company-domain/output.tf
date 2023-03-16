output "web-serivce-cluster-ip" {
  value = kubernetes_service_v1.company_service.metadata[0].name
}