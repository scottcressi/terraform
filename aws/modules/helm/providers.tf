provider "aws" {
  region = var.region
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}

provider "kubernetes" {
  config_path = "../eks/kubeconfig_my-cluster"
#  host                   = data.terraform_remote_state.eks.cluster_endpoint
#  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_eks_cluster.cluster.certificate_authority.0.data)
#  token                  = data.terraform_remote_state.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    config_path = "../eks/kubeconfig_my-cluster"
  }
}
