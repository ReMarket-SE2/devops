data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.private.name
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 20
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.zone
  cluster    = google_container_cluster.primary.name

  version = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "${var.project_id}-prod"
    }

    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
