module "helm" {
  source      = "../../../../../modules/helm"
  environment = var.environment
  region      = var.region
  zone        = var.zone
  state_key    = var.state_key
  state_bucket = var.state_bucket
}
