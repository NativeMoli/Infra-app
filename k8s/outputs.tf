output "cluster_name" {
  value = google_container_cluster.k8s_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.k8s_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = lookup(google_container_cluster.k8s_cluster.master_auth[0], "cluster_ca_certificate", "")
}


output "node_pool_name" {
  value = google_container_node_pool.primary_nodes.name
}
