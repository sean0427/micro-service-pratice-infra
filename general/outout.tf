output "kafaka_endpoint_cluster_ip" {
  value = "${kubernetes_service_v1.kafka_service.metadata[0].name}.${kubernetes_namespace_v1.namespace.metadata[0].name}:${kubernetes_service_v1.kafka_service.spec[0].port[0].port}"
}