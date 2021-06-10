module "ec2" {
  source       = "../../../../../modules/ec2"
  environment  = var.environment
  region       = var.region
  zone         = var.zone
  state_key    = var.state_key
  state_bucket = var.state_bucket
}
