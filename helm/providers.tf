provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}

provider "aws" {
  region = "us-east-1"
}
