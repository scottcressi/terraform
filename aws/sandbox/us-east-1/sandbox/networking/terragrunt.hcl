terraform {
  source = "git::ssh://git@github.com/scottcressi/terraform-modules.git//modules/networking"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  region      = "us-east-1"
  company     = "example"
  environment = "sandbox"
  cidr        = "10.0.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e",
  ]
  private_subnets = [
    "10.0.1.0/7",
    "10.0.2.0/7",
    "10.0.3.0/7",
    "10.0.4.0/7",
    "10.0.5.0/7",
  ]
}
