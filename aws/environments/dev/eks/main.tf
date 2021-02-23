module "eks" {
  source = "../../../modules/eks"
  environment = var.environment
  region = var.region
}
