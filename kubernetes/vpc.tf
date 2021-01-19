module "vpc" {
  create_vpc         = var.location == "aws" ? true : false
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.66.0"
  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true

  private_subnet_tags = {
    "kubernetes.io/cluster/k8s.org.com" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/k8s.org.com" = "owned"
  }

  customer_gateways = {
    IP1 = {
      bgp_asn    = 65112
      ip_address = "1.2.3.4"
    }
  }

}
