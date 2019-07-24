remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terragrunt-state-sandbox-20190112121212"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terragrunt-locks-sandbox"
  }
}
inputs = {
  aws_region                   = "us-east-1"
  aws_profile                  = "default"
  tfstate_global_bucket        = "terragrunt-state-sandbox-20190112121212"
  tfstate_global_bucket_region = "us-east-1"
}
