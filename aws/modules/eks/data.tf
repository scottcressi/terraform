data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = var.state_bucket
    key            = var.state_key
    region         = var.region
    profile = "personal"
  }
}
