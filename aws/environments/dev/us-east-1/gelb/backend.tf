terraform {
  required_version = "0.14.8"

  #backend "pg" {}

  backend "s3" {
    bucket = "terraform-state-7ac65cd8-518c-40db-99a7-8948133592ca"
    key    = "dev/us-east-1/gelb/terraform.tfstate"
    region = "us-east-1"
    #dynamodb_table = "terraform_state"
  }

  required_providers {
    aws = {
      version = "3.30.0"
    }
    random = {
      version = "3.0.1"
    }
    local = {
      version = "2.0.0"
    }
    null = {
      version = "3.0.0"
    }
    template = {
      version = "2.2.0"
    }
  }

}
