data "template_file" "inventory" {
  template = file("${path.module}/inventory.tpl")

  vars = {
    bastion_ip       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
    cicd_internal_ip = google_compute_instance.cicd.network_interface[0].network_ip
    web_private_ip   = google_compute_instance.web.network_interface[0].network_ip
    ssh_user         = var.ssh_user
  }
}

resource "local_file" "inventory" {
  content  = data.template_file.inventory.rendered
  filename = "${path.module}/inventory.ini"
}
