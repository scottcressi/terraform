data "terraform_remote_state" "aws_eks_cluster_auth" {
  backend = "s3"
  config = {
    bucket         = var.state_bucket
    key            = var.state_key
    region         = var.region
    profile = "personal"
  }
}
