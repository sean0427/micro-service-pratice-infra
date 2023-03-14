resource "kubernetes_service_v1" "kafka_service" {
  metadata {
    name      = "kafka-service"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  spec {
    selector = {
      type = "message-broker"
      app  = "kafka"
    }

    port {
      name        = "9092"
      port        = 9092
      target_port = 9092
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_config_map_v1" "kafka_config" {
  metadata {
    name      = "kafka-config"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    KAFKA_ENABLE_KRAFT                       = "yes"
    KAFKA_CFG_PROCESS_ROLES                  = "broker,controller"
    KAFKA_CFG_CONTROLLER_LISTENER_NAMES      = "CONTROLLER"
    KAFKA_CFG_LISTENERS                      = "PLAINTEXT://:9092,CONTROLLER://:9093"
    KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
    KAFKA_CFG_ADVERTISED_LISTENERS           = "PLAINTEXT://${kubernetes_service_v1.kafka_service.metadata[0].name}.${kubernetes_namespace_v1.namespace.metadata[0].name}:${kubernetes_service_v1.kafka_service.spec[0].port[0].port}"
    KAFKA_BROKER_ID                          = "1"
    KAFKA_CFG_CONTROLLER_QUORUM_VOTERS       = "1@127.0.0.1:9093"
    ALLOW_PLAINTEXT_LISTENER                 = "yes"
  }
}

resource "kubernetes_stateful_set_v1" "kafka-message-broker" {
  metadata {
    name      = "kafka-stateful-set"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    labels = {
      app  = "kafka"
      type = "message-broker"
    }
  }

  spec {
    service_name           = "kafaka"
    replicas               = 1
    revision_history_limit = 2
    selector {
      match_labels = {
        app  = "kafka"
        type = "message-broker"
      }
    }

    template {
      metadata {
        labels = {
          app       = "kafka"
          type      = "message-broker"
          namespace = kubernetes_namespace_v1.namespace.metadata[0].name
        }
      }

      spec {

        container {
          name              = "message-stream-kafka"
          image             = "bitnami/kafka:latest"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "kafka"
            container_port = 9092
            protocol       = "TCP"
          }

          # currently useless, only one pod
          # port {
          #   name           = "controller"
          #   container_port = 9093
          #   protocol       = "TCP"
          # }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.kafka_config.metadata[0].name
            }
          }

          volume_mount {
            name       = "/bitnami/kafka"
            mount_path = "/bitnami/kafka"
            read_only  = false
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name      = "kafka-volume-claim"
        namespace = kubernetes_namespace_v1.namespace.metadata[0].name
      }
      spec {
        access_modes       = ["ReadWriteMany"]
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
