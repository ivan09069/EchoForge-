# Terraform variables for EchoForge GCP backup infrastructure
# Define input variables for customization

variable "gcp_project_id" {
  description = "GCP Project ID for backup infrastructure"
  type        = string
  # No default - user must provide their project ID
}

variable "gcp_region" {
  description = "GCP region for backup infrastructure"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Unique Cloud Storage bucket name (globally unique, lowercase, hyphens allowed)"
  type        = string
  # No default - user must provide a unique bucket name
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource tagging (lowercase, hyphens allowed)"
  type        = string
  default     = "echoforge"
}
