output "bastion_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "web_private_ip" {
  value = google_compute_instance.web.network_interface[0].network_ip
  description = "Private IP of Web server"
}

output "cicd_internal_ip" {
  value = google_compute_instance.cicd.network_interface[0].network_ip
}

output "cloudsql_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}

output "database_name" {
  value = google_sql_database.db.name
}

output "database_username" {
  value = google_sql_user.db_user.name
}

output "database_password" {
  value     = google_sql_user.db_user.password
  sensitive = true
}

output "cloudsql_dns" {
  value = google_dns_record_set.sql_dns.name
}