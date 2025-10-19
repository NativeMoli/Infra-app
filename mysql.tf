# Reserved range for private services
resource "google_compute_global_address" "private_service_address" {
  name          = "private-service-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# Service networking connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_address.name]
}

# Cloud SQL (MySQL)
resource "google_sql_database_instance" "db_instance" {
  name             = "my-db-mysql"
  region           = var.region
  database_version = "MYSQL_5_6"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }

  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Database всередині інстансу
resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
}

# Користувач
resource "google_sql_user" "db_user" {
  name     = var.db_username
  instance = google_sql_database_instance.db_instance.name
  password = var.db_password
}
