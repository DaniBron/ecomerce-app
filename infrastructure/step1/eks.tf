module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "ecommerce-cluster"
  cluster_version = "1.26"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  eks_managed_node_groups = {
    eks_nodes = {
      desired_size  = 2
      max_size      = 2
      min_size      = 1
      instance_type = var.eks_instance_type
    }
  }

  cluster_endpoint_public_access  = true

  # Automatically grant cluster admin permissions to the IAM user or role that creates the cluster
  enable_cluster_creator_admin_permissions = true
}