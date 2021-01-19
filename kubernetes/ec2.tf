module "ec2_with_t3_unlimited" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.16.0"
  instance_count              = 1
  name                        = "example-t3-unlimited"
  ami                         = "ami-00e87074e52e6c9f9"
  instance_type               = "t3.large"
  cpu_credits                 = "unlimited"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  associate_public_ip_address = true
  disable_api_termination     = true
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = module.ec2_with_t3_unlimited.*.public_ip
}
