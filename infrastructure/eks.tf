module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "ecommerce-cluster"
  cluster_version = "1.26"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids  # Subnets for node groups and control plane (if not specified separately)

  # EKS Managed Node Groups (replacing the old 'node_groups' syntax)
  eks_managed_node_groups = {
    eks_nodes = {
      desired_size = 2
      max_size     = 2
      min_size     = 1
      instance_type = var.eks_instance_type
    }
  }
}
