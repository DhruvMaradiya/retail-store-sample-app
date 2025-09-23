# ---------------------------------------------------------------------
# VPC & SUBNETS
# ---------------------------------------------------------------------
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.gcp_project_id
  network_name = "${local.cluster_name}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    for i, cidr in local.public_subnets :
    {
      subnet_name           = "public-${i}"
      subnet_ip             = cidr
      subnet_region         = var.gcp_region
      subnet_private_access = false
      subnet_flow_logs      = false
      description           = "Public subnet ${i}"
    }
  ]

  secondary_ranges = {
    "public-0" = [
      { range_name = "pods", ip_cidr_range = "10.1.0.0/20" },
      { range_name = "services", ip_cidr_range = "10.2.0.0/20" },
    ]
  }

  firewall_rules = [
    {
      name        = "allow-health-check"
      description = "Google LB health checks"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443", "10254"]
      }]
    },
    {
      name        = "allow-nodeport"
      description = "NodePort range inside VPC"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = [var.vpc_cidr]
      allow = [{
        protocol = "tcp"
        ports    = ["30000-32767"]
      }]
    }
  ]
}

# Cloud Router + NAT – depends on VPC above
resource "google_compute_router" "nat_router" {
  name    = "${local.cluster_name}-router"
  region  = var.gcp_region
  network = module.vpc.network_name
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.cluster_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


# ---------------------------------------------------------------------
# GKE AUTOPILOT CLUSTER 
# ---------------------------------------------------------------------
module "gke_autopilot" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "~> 30.0"

  project_id         = var.gcp_project_id
  name               = local.cluster_name
  region             = var.gcp_region
  network            = module.vpc.network_name
  subnetwork         = module.vpc.subnets_names[0] # public-0
  ip_range_pods      = "pods"
  ip_range_services  = "services"
  release_channel    = "REGULAR"
  kubernetes_version = var.kubernetes_version

  cluster_resource_labels = local.common_tags
  deletion_protection = false   
}