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
