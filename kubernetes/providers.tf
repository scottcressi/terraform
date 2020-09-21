provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}
