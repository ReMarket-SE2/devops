resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
  routing_mode           = "REGIONAL"
  delete_default_routes_on_create = true
}

resource "google_compute_route" "default_route" {
  name       = "${var.project_id}-default-route"
  dest_range = "0.0.0.0/0"
  network    = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
}

# Subnet
resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.10.0.0/19"
  region        = var.region
  network       = google_compute_network.vpc.name
  stack_type = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "private" {
  name          = "private"
  ip_cidr_range = "10.10.32.0/19"
  region        = var.region
  network       = google_compute_network.vpc.name
  stack_type = "IPV4_ONLY"
}

resource "google_compute_address" "nat" {
  name   = "nat"
  region = var.region
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  region = var.region
  router = google_compute_router.router.name

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips               = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
