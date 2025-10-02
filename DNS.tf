resource "google_dns_managed_zone" "main" {
  name     = "${var.env_name}-zone"
  dns_name = "${var.env_name}-itca.com." # наприклад: dev-itca.com
}



resource "google_dns_record_set" "sql_dns" {
name         = "${var.env_name}-itca.${google_dns_managed_zone.main.dns_name}"
type         = "A"
ttl          = 300
managed_zone = google_dns_managed_zone.main.name

rrdatas = [google_sql_database_instance.db_instance.private_ip_address]
}
