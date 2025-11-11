# Terraform variables for EchoForge GCP backup infrastructure

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for backup infrastructure"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Unique GCS bucket name (must be globally unique)"
  type        = string
}

variable "keyring_name" {
  description = "Name of the KMS key ring"
  type        = string
  default     = "echoforge-backup-keyring"
}

variable "key_name" {
  description = "Name of the KMS crypto key"
  type        = string
  default     = "echoforge-backup-key"
}

variable "service_account_id" {
  description = "Service account ID (must be unique within project, 6-30 chars)"
  type        = string
  default     = "echoforge-backup-sa"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "echoforge"
}
