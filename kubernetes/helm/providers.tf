provider "aws" {
  region = var.region
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig_my-cluster"
  }
}
