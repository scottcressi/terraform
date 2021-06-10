provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.terraform_remote_state.aws_eks_cluster_auth.cluster.token
}
