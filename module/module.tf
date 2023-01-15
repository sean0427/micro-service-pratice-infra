module "product-domain" {
  source = "../product-domain"

  resource_group = local.groups
  namespace_name = local.kubernetes_namesapce
  environment = "local"
}

module "user-domain" {
  source = "../user-domain"

  resource_group = local.groups
  namespace_name = local.kubernetes_namesapce
  environment = "local"
}
