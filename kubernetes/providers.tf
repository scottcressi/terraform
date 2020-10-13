provider "aws" {
  region  = var.region
  version = "3.10.0"
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
  version = "2.14.0"
}

provider "helm" {
  version = "1.3.2"
}

terraform {
  required_version = "0.13.4"
}

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
  version                = "1.13.2"
}

provider "random" {
  version = "3.0.0"
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "3.0.0"
}

provider "template" {
  version = "2.2.0"
}
