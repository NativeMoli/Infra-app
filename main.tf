terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Custom VPC for project"
}

resource "google_compute_subnetwork" "public_subnet" {
  count                    = length(var.zones)
  name                     = "public-subnet-${count.index}"
  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 4, count.index)
  region                   = var.region
  network                  = google_compute_network.vpc.name
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private_subnet" {
  count                    = length(var.zones)
  name                     = "private-subnet-${count.index}"
  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 4, count.index + length(var.zones))
  region                   = var.region
  network                  = google_compute_network.vpc.name
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.vpc.name
  region  = var.region

  depends_on = [google_compute_subnetwork.private_subnet]
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.private_subnet
    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  depends_on = [google_compute_router.nat_router, google_compute_subnetwork.private_subnet]
}

resource "google_compute_firewall" "bastion_ssh" {
  name    = "bastion-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.my_ip_cidr]
  target_tags   = ["bastion"]
}

resource "google_compute_instance" "bastion" {
  name         = "bastion-instance"
  machine_type = "e2-micro"
  zone         = var.zones[0]

  # Вимикаємо захист від видалення VM
  deletion_protection = false

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork    = google_compute_subnetwork.public_subnet[0].name
    access_config {}
  }

  tags = ["bastion"]
}

resource "google_compute_instance" "cicd_instance" {
  name         = "cicd-instance"
  machine_type = "e2-micro"
  zone         = var.zones[0]

  deletion_protection = false

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet[0].name
    # без доступу до публічної IP
  }

  tags = ["cicd"]

  depends_on = [google_compute_router_nat.nat]
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_sql_database_instance" "default" {
  name             = "rds-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      ssl_mode       = "ENCRYPTED_ONLY"
    }
  }
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zones" {
  type    = list(string)
  default = ["us-central1-a", "us-central1-b"]
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/22"
}

variable "my_ip_cidr" {
  type        = string
  description = "Ваш публічний IP адрес з суфіксом /32 для SSH доступу"
}
