provider "aws" {
  region = var.region
  default_tags {
    tags = {
      environment = var.environment
    }
  }
}

provider "vault" {
  address = "http://vault-k8s.${var.environment}.${var.zone}.com:8200"
}
