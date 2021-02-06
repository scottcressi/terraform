provider "aws" {
  region = var.region
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig_my-cluster"
  }
}
