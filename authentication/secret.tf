resource "kubernetes_secret_v1" "JWT_SECRET_KEY" {
  metadata {
    name      = "web-service-jwt-key"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
  data = {
    JWT_KEY        = tls_private_key.JWT_KEY.private_key_pem
    JWT_KEY_PUBLIC = tls_private_key.JWT_KEY.public_key_pem
  }
}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "JWT_KEY" {
  algorithm = "ED25519"
}