
data "google_container_cluster" "existing_cluster" {
  name     = var.cluster_name
  location = var.region
}

output "gke_cluster_name" {
  value = data.google_container_cluster.existing_cluster.name
}

output "gke_cluster_location" {
  value = data.google_container_cluster.existing_cluster.location
}

output "gke_cluster_endpoint" {
  value     = data.google_container_cluster.existing_cluster.endpoint
  sensitive = true
}
