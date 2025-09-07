output "bastion_public_ip" {
  description = "Публічна IP адреса Bastion інстансу"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_private_ip" {
  description = "Приватна IP адреса Bastion інстансу"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "cicd_private_ip" {
  description = "Приватна IP адреса CI/CD інстансу"
  value       = google_compute_instance.cicd_instance.network_interface[0].network_ip
}

output "sql_instance_connection_name" {
  description = "Ім'я підключення Cloud SQL інстансу"
  value       = google_sql_database_instance.default.connection_name
}