resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"

  azs             = slice(data.google_compute_zones.available.names, 0, 3)
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]

  common_tags = {
    environment = var.environment
    project     = "retail-store"
    managed_by  = "terraform"
    created_by  = "dhruv"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}