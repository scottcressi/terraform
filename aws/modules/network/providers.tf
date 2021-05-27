provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      environment = var.environment
    }
  }
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}
