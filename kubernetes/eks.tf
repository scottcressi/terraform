module "my-cluster" {
  create_eks      = var.location == "aws" ? true : false
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = "my-cluster"
  cluster_version = "1.17"
  subnets         = module.vpc.public_subnets
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

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
}
