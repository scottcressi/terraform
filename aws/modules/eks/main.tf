module "my-cluster" {

  source          = "terraform-aws-modules/eks/aws"
  version         = "14.0.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = data.terraform_remote_state.network.outputs.private_subnets
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id

  node_groups = {
    example = {
      desired_capacity = 3
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["m5.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        group = "test"
      }
      additional_tags = {
        ExtraTag = "example"
      }
    }
    example1 = {
      desired_capacity = 3
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["m5.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        group = "test1"
      }
      additional_tags = {
        ExtraTag = "example1"
      }
    }
  }

}
