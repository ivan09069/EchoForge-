# Terraform variables for EchoForge backup infrastructure
# Define input variables for customization

variable "aws_region" {
  description = "AWS region for backup infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Unique S3 bucket name for backups (must be globally unique)"
  type        = string
  # No default - user must provide a unique bucket name
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
