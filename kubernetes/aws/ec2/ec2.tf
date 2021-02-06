module "ec2_with_t3_unlimited" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.16.0"
  instance_count              = 1
  name                        = "example-t3-unlimited"
  ami                         = "ami-00e87074e52e6c9f9" # centos
  instance_type               = "t3.small"
  cpu_credits                 = "unlimited"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnets[0]
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

locals {
  instance-userdata = <<EOF
#!/bin/bash
echo foo > /tmp/foo.txt
sudo yum install -y telnet
EOF
}

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 1
      to_port     = 65535
      protocol    = "tcp"
      #description = "Service name"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
