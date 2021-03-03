module "ec2_with_t3_unlimited" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.17.0"
  instance_count              = 1
  name                        = "example-t3-unlimited"
  ami                         = "ami-00e87074e52e6c9f9" # centos
  instance_type               = "t3.small"
  cpu_credits                 = "unlimited"
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnets[0]
  vpc_security_group_ids      = [module.vote_service_sg.this_security_group_id]
  associate_public_ip_address = true
  disable_api_termination     = false
  user_data_base64            = base64encode(local.instance-userdata)
  key_name                    = aws_key_pair.mykeypair.key_name
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "vote_service_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "3.17.0"
  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
