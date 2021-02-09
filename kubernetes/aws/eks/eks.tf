module "my-cluster" {

  source          = "terraform-aws-modules/eks/aws"
  version         = "13.2.1"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id

  worker_groups = [
    {
      instance_type        = "m5.large"
      asg_min_size         = 4
      asg_max_size         = 6
      asg_desired_capacity = 5

    }
  ]
}

#resource "aws_globalaccelerator_endpoint_group" "example" {
#  listener_arn = aws_globalaccelerator_listener.example.id
#
#  endpoint_configuration {
#    endpoint_id = aws_lb.example.arn
#    weight      = 100
#  }
#}
