# Main Terraform configuration for EchoForge Azure backup infrastructure
# Creates Azure Storage Account, Key Vault, and Service Principal with least-privilege access

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource group for all backup resources
resource "azurerm_resource_group" "backup_rg" {
  name     = "${var.project_name}-backup-rg"
  location = var.azure_location

  tags = {
    Name        = "${var.project_name}-backup-rg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Storage account for backup data
# Configured with encryption, versioning, and secure transfer
resource "azurerm_storage_account" "backup_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.backup_rg.name
  location                 = azurerm_resource_group.backup_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant storage
  account_kind             = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

  # Blob encryption settings
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = {
    Name        = "${var.project_name}-backup-storage"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Blob container for backups
resource "azurerm_storage_container" "backup_container" {
  name                  = "backups"
  storage_account_name  = azurerm_storage_account.backup_storage.name
  container_access_type = "private"
}

# Lifecycle management policy for cost optimization
resource "azurerm_storage_management_policy" "backup_lifecycle" {
  storage_account_id = azurerm_storage_account.backup_storage.id

  rule {
    name    = "backup-lifecycle-rule"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["backups/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
      }

      version {
        delete_after_days_since_creation = 365
      }
    }
  }
}

# Key Vault for storing encryption keys
resource "azurerm_key_vault" "backup_kv" {
  name                = "${var.project_name}-backup-kv"
  location            = azurerm_resource_group.backup_rg.location
  resource_group_name = azurerm_resource_group.backup_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Security settings
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = false
  soft_delete_retention_days      = 7

  tags = {
    Name        = "${var.project_name}-backup-kv"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Key Vault access policy for current user (for initial setup)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.backup_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Purge",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
  ]
}

# Azure AD Application for backup operations
resource "azuread_application" "backup_app" {
  display_name = "${var.project_name}-backup-app"
}

# Service Principal for the application
resource "azuread_service_principal" "backup_sp" {
  client_id = azuread_application.backup_app.client_id
}

# Service Principal password (client secret)
resource "azuread_service_principal_password" "backup_sp_password" {
  service_principal_id = azuread_service_principal.backup_sp.id
  end_date_relative    = "8760h" # 1 year
}

# Role assignment: Storage Blob Data Contributor on the storage account
# Provides least-privilege access for backup operations
resource "azurerm_role_assignment" "backup_sp_storage" {
  scope                = azurerm_storage_account.backup_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.backup_sp.object_id
}

# Key Vault access policy for Service Principal
resource "azurerm_key_vault_access_policy" "backup_sp" {
  key_vault_id = azurerm_key_vault.backup_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.backup_sp.object_id

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}

# Customer-managed encryption key in Key Vault
resource "azurerm_key_vault_key" "backup_key" {
  name         = "${var.project_name}-backup-key"
  key_vault_id = azurerm_key_vault.backup_kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]

  tags = {
    Name        = "${var.project_name}-backup-key"
    Environment = var.environment
    Project     = var.project_name
  }
}
