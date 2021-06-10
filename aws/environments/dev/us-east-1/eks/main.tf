module "eks" {
  source       = "../../../../../modules/eks"
  environment  = var.environment
  region       = var.region
  state_bucket = var.state_bucket
  state_key    = var.state_key
}
