terraform {
  required_version = "0.14.5"

  #backend "pg" {}

  #backend "s3" {
  #  bucket         = "374012539393-terraform-state"
  #  key            = "terraform.tfstate"
  #  region         = "us-east-1"
  #  #dynamodb_table = "terraform_state"
  #}

  required_providers {
    azurerm = {
      version = "2.44.0"
    }
  }

}
