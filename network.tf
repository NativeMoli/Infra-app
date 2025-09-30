resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Public Subnets
resource "google_compute_subnetwork" "public_a" {
  name          = "public-a"
  ip_cidr_range = "192.168.0.0/27"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "public_b" {
  name          = "public-b"
  ip_cidr_range = "192.168.0.32/27"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Private Subnets
resource "google_compute_subnetwork" "private_a" {
  name                      = "private-a"
  ip_cidr_range             = "192.168.0.64/27"
  region                    = var.region
  network                   = google_compute_network.vpc.id
  private_ip_google_access  = true
}

resource "google_compute_subnetwork" "private_b" {
  name                      = "private-b"
  ip_cidr_range             = "192.168.0.96/27"
  region                    = var.region
  network                   = google_compute_network.vpc.id
  private_ip_google_access  = true
}

# Internet route (як Internet Gateway в AWS)
resource "google_compute_route" "default_internet" {
  name       = "default-internet"
  network    = google_compute_network.vpc.name
  dest_range = "0.0.0.0/0"
  priority   = 1000

  next_hop_gateway = "default-internet-gateway"
}
