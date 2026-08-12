module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Groupe de nœuds EC2 (Worker Nodes) exécutant vos Pods
  eks_managed_node_groups = {
    expensy_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"] # Bonne taille pour un backend + frontend
      capacity_type  = "ON_DEMAND"   # Ou "SPOT" pour réduire les coûts

      labels = {
        Environment = var.environment
      }
    }
  }

  # Accès administrateur au cluster
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = var.environment
    Project     = "Expensy"
  }
}