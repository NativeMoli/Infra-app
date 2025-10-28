variable "project_id" {}
variable "region" { default = "europe-west1" }
variable "zone_a" { default = "europe-west1-b" }
variable "zone_b" { default = "europe-west1-c" }
variable "ssh_user" { default = "ubuntu" }
variable "ssh_public_key" { default = "~/.ssh/id_rsa.pub" }
variable "my_ip" { description = "Your public IP in CIDR format, e.g. 1.2.3.4/32" }
variable "credentials_file" {}
variable "env_name" {
  description = "Environment name (used in DNS and resource names, e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}


