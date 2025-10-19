

# Генерація inventory.ini для Ansible
resource "local_file" "ansible_inventory" {
  filename = "${path.module}./ansible/inventory.ini"

  content = <<EOT
[runner]
192.168.0.66 ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=ubuntu@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} -o StrictHostKeyChecking=no'

[web]
192.168.0.67 ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=ubuntu@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} -o StrictHostKeyChecking=no'

[bastion]
${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/id_rsa
EOT
}
