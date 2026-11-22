
variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "project-918e19aa-5e72-4ef1-a47"
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-east4"
}

variable "cluster_name" {
  description = "Existing GKE cluster name"
  type        = string
  default     = "cluster1"
}
