provider "aws" {
  region  = "us-east-1"
  version = "3.9.0"
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
  version = "2.14.0"
}

provider "helm" {
  version = "1.3.1"
}

terraform {
  required_version = "0.13.4"
}
