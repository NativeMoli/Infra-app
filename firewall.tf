# SSH only from your IP to Bastion
resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.my_ip]
  target_tags   = ["bastion"]
}

# Internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["192.168.0.0/25"]
}
