# Terraform variables for EchoForge Azure backup infrastructure
# Define input variables for customization

variable "azure_location" {
  description = "Azure region for backup infrastructure"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Unique Azure Storage Account name (3-24 lowercase alphanumeric characters, globally unique)"
  type        = string
  # No default - user must provide a unique storage account name
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource tagging (lowercase, no special characters)"
  type        = string
  default     = "echoforge"
}
