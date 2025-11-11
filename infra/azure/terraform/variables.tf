# Terraform variables for EchoForge Azure backup infrastructure

variable "location" {
  description = "Azure region for backup infrastructure"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group (will be created if create_resource_group is true)"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group (false to use existing)"
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Unique Key Vault name (must be globally unique, 3-24 chars)"
  type        = string
}

variable "storage_account_name" {
  description = "Unique Storage Account name (must be globally unique, 3-24 chars, lowercase alphanumeric)"
  type        = string
}

variable "container_name" {
  description = "Name of the blob container for backups"
  type        = string
  default     = "backups"
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
