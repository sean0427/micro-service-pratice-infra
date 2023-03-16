module "general" {
  source = "../general"

  resource_group = local.groups
  environment    = local.environment
}

module "general-outbox" {
  source = "../outbox"

  environment    = local.environment
  namespace_name = "g-outbox-service"

  kafaka_path = module.general.kafaka_endpoint_cluster_ip
}

module "company-domain" {
  source = "../company-domain"

  environment    = local.environment
  namespace_name = "p-company-domain"
  outbox_path    = module.general-outbox.web-serivce-cluster-ip
}

module "product-domain" {
  source = "../product-domain"

  resource_group = local.groups
  environment    = local.environment
  namespace_name = "p-product-domain"
}

module "user-domain" {
  source = "../user-domain"

  resource_group = local.groups
  environment    = local.environment
  namespace_name = local.user_name_space
}


module "auth-server" {
  source = "../authentication"

  environment    = local.environment
  namespace_name = "p-auth-server"
  resource_group = local.groups

  user_domain_path = "${module.user-domain.web-serivce-cluster-ip}.${local.user_name_space}:80"
}
