module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.1.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size       = var.asg_min_size
      max_size       = var.asg_max_size
      desired_size   = var.asg_desired_capacity
      instance_types = [var.instance_type]
    }
  }
}
