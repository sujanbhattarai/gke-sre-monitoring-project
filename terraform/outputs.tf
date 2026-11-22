
output "project_id" {
  description = "Google Cloud project ID"
  value       = var.project_id
}

output "region" {
  description = "Google Cloud region"
  value       = var.region
}

output "vpc_name" {
  description = "Name of the Terraform-managed VPC"
  value       = google_compute_network.sre_vpc.name
}

