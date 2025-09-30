# Bastion host
resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = var.zone_a

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.public_a.id
    access_config {} # External IP
  }

  tags = ["bastion"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }
}

# Web server (private, Nginx)
resource "google_compute_instance" "web" {
  name         = "web-instance"
  machine_type = "e2-micro"
  zone         = var.zone_b

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_a.id
    # No external IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }
}

# CI/CD instance (private)
resource "google_compute_instance" "cicd" {
  name         = "cicd-instance"
  machine_type = "e2-medium" #"e2-micro"
  zone         = var.zone_b

  allow_stopping_for_update = true  # <- додати сюди

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_a.id
    # No external IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }
}
