terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# GKE Cluster
resource "google_container_cluster" "k8s_cluster" {
  name     = "eschool-cluster"
  location = var.zone

  initial_node_count = 1
  remove_default_node_pool = true

  deletion_protection = false

  networking_mode = "VPC_NATIVE"
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  cluster    = google_container_cluster.k8s_cluster.name
  location   = var.zone
  initial_node_count = var.node_count

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
