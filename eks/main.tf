module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.50.0"
  name                  = "my-vpc"
  cidr                  = "10.0.0.0/16"
  azs                   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets        = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway    = true
  enable_vpn_gateway    = true
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = "my-cluster"
  cluster_version = "1.17"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 3
    }
  ]
}

module "kms" {
  source        = "Cloud-42/kms/aws"
  version       = "1.2.0"
  alias_name    = "test1"
  description   = "test"
}
