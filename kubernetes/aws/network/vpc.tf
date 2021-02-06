module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.68.0"
  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = data.aws_availability_zones.available.names
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  customer_gateways = {
    IP1 = {
      bgp_asn    = 65112
      ip_address = "1.2.3.4"
    }
  }

}

data "aws_availability_zones" "available" {
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.private_subnets
}
