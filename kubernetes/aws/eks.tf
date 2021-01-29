module "my-cluster" {

  depends_on = [
    module.vpc
  ]

  source          = "terraform-aws-modules/eks/aws"
  version         = "14.0.0"
  cluster_name    = local.cluster_name
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
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

locals {
  cluster_name = "my-cluster"
}
