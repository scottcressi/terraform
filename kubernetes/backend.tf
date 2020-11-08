terraform {
  required_version = "0.13.5"
  backend "s3" {
    bucket         = "374012539393-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "terraform_state"
  }
}
