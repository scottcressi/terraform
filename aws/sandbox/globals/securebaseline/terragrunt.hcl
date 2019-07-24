terraform {
  source = "git::ssh://git@github.com/scottcressi/terraform-modules.git//modules/globals/securebaseline"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  region = "us-east-1"
}
