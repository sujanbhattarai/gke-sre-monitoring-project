
resource "google_compute_network" "sre_vpc" {
  name                    = "sre-monitoring-vpc"
  auto_create_subnetworks = false
  description             = "VPC network for GKE SRE monitoring project"
}
