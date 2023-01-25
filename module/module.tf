# TODO
# module "product-domain" {
#   source = "../product-domain"

# resource_group = local.groups
# environment    = local.environment
# namespace_name = "product-domain"
# }


module "general" {
  source = "../general"

  resource_group = local.groups
  environment    = local.environment
}

module "user-domain" {
  source = "../user-domain"

  resource_group = local.groups
  environment    = local.environment
  namespace_name = "p-user-domain"
}


module "auth-server" {
  source = "../authentication"

  environment    = local.environment
  namespace_name = "p-auth-server"
  resource_group = local.groups

  user_domain_path = module.user-domain.web-serivce-cluster-ip
}