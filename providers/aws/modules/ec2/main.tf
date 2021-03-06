module "ec2_with_t3_unlimited" {
  source                  = "terraform-aws-modules/ec2-instance/aws"
  version                 = "2.19.0"
  instance_count          = 1
  name                    = "example-t3-unlimited"
  ami                     = "ami-0de4dcbef8f2fd507" # ubuntu 21.04
  instance_type           = "t3.micro"
  cpu_credits             = "unlimited"
  subnet_id               = data.terraform_remote_state.network.outputs.public_subnets[0]
  vpc_security_group_ids  = [module.vote_service_sg.security_group_id]
  disable_api_termination = false
  user_data_base64        = base64encode(file("user_data.sh"))
  key_name                = aws_key_pair.mykeypair.key_name
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2_with_t3_unlimited.id[0]
  allocation_id = aws_eip.example.id
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(module.ssh_key_pair.public_key_filename)
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.some_ssh_key.id
  secret_string = module.ssh_key_pair.private_key
}

resource "aws_secretsmanager_secret" "some_ssh_key" {
  recovery_window_in_days = 0
  name = "secret/ssh_keys/some_ssh_key"
}

module "ssh_key_pair" {
  source                = "cloudposse/key-pair/aws"
  version               = "0.18.0"
  namespace             = "eg"
  stage                 = "prod"
  name                  = "app"
  ssh_public_key_path   = "secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}

module "vote_service_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.2.0"
  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
