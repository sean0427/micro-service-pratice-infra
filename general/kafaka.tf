resource "kubernetes_service" "kafka_service" {
  metadata {
    name = "kafka-service"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "kafka"
    }

    port {
      name = "9092"
      port = 9092
      target_port = 9092
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_config_map_v1" "kafka_config" {
  metadata {
    name = "kafka-env"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    KAFKA_ENABLE_KRAFT = "yes"
    KAFKA_CFG_PROCESS_ROLES = "broker,controller"
    KAFKA_CFG_CONTROLLER_LISTENER_NAMES = "CONTROLLER"
    KAFKA_CFG_LISTENERS = "PLAINTEXT://:9092,CONTROLLER://:9093"
    KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
    KAFKA_CFG_ADVERTISED_LISTENERS = "PLAINTEXT://127.0.0.1:9092"
    KAFKA_BROKER_ID = "1"
    KAFKA_CFG_CONTROLLER_QUORUM_VOTERS = "1@127.0.0.1:9093"
    ALLOW_PLAINTEXT_LISTENER = "yes"
  }
}

resource "kubernetes_stateful_set_v1" "stream-kafka" {
  metadata {
    name = "kafka"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app = "kafka"
      type = "stream"
    }
  }

  spec {
    service_name = "kafaka"
    replicas = 1
    revision_history_limit = 2
    selector {
      match_labels = {
        app = "kafka"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
        }
      }

      spec {
        
        container {
          name  = "kafka"
          image = "bitnami/kafka:latest"
          image_pull_policy = "IfNotPresent"

          port {
            name = "kafka"
            container_port = 9092
            protocol = "TCP"
          }

          port {
            name = "controller"
            container_port = 9093
            protocol = "TCP"
          }

          env_from {
              config_map_ref  {
                name = "kafka-config"
              }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
      }
      spec {
        access_modes = ["ReadWriteMany"]
        storage_class_name = "local"
        resources {
          requests = {
            storage = "500Mi"
          }
        }
      }
    }
  }
}
