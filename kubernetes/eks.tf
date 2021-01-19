module "my-cluster" {
  create_eks      = var.location == "aws" ? true : false
  source          = "terraform-aws-modules/eks/aws"
  version         = "13.2.1"
  cluster_name    = "my-cluster"
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type        = "m5.xlarge"
      asg_min_size         = 4
      asg_max_size         = 6
      asg_desired_capacity = 5
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  count = var.location == "aws" ? 1 : 0
  name  = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.location == "aws" ? 1 : 0
  name  = module.my-cluster.cluster_id
}
