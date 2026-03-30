module "vpc" {
  source = "./modules/vpc"

  name                 = var.name
  tags                 = var.tags
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  name                    = var.name
  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = var.vpc_cidr
  cluster_subnet_ids      = module.vpc.private_subnet_ids
  private_subnet_a        = module.vpc.private_subnet_ids[0]
  private_subnet_b        = module.vpc.private_subnet_ids[1]
  endpoint_private_access = true
  endpoint_public_access  = true
  node_instance_type      = var.node_instance_type
  node_desired_size       = var.node_desired_size
  node_min_size           = var.node_min_size
  node_max_size           = var.node_max_size
  tags                    = var.tags
}
