# Main Terraform configuration for EchoForge Azure backup infrastructure
# Creates Resource Group, Key Vault, Storage Account with CMK encryption

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
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

# Resource Group (optional - can use existing)
resource "azurerm_resource_group" "backup_rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Data source for existing resource group
data "azurerm_resource_group" "existing_rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.backup_rg[0].name : data.azurerm_resource_group.existing_rg[0].name
  resource_group_id   = var.create_resource_group ? azurerm_resource_group.backup_rg[0].id : data.azurerm_resource_group.existing_rg[0].id
}

# Key Vault for storing keys and secrets
resource "azurerm_key_vault" "backup_kv" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = local.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  enabled_for_disk_encryption = true
  enabled_for_deployment      = false

  tags = {
    Name        = "${var.project_name}-backup-keyvault"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.backup_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Recover", "Purge",
    "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Purge"
  ]
}

# RSA Key for CMK encryption
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
    azurerm_key_vault_access_policy.deployer
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Storage Account with system-assigned identity
resource "azurerm_storage_account" "backup_storage" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # System-assigned managed identity for CMK
  identity {
    type = "SystemAssigned"
  }

  # Versioning and change feed
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Name        = "${var.project_name}-backup-storage"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Access policy for Storage Account managed identity to use Key Vault key
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.backup_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.backup_storage.identity[0].principal_id

  key_permissions = [
    "Get", "UnwrapKey", "WrapKey"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.deployer
  ]
}

# Customer-Managed Key encryption for Storage Account
resource "azurerm_storage_account_customer_managed_key" "backup_cmk" {
  storage_account_id = azurerm_storage_account.backup_storage.id
  key_vault_id       = azurerm_key_vault.backup_kv.id
  key_name           = azurerm_key_vault_key.backup_key.name

  depends_on = [
    azurerm_key_vault_access_policy.storage
  ]
}

# Private Blob container for backups
resource "azurerm_storage_container" "backup_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.backup_storage.name
  container_access_type = "private"
}

# Management policy for lifecycle management
resource "azurerm_storage_management_policy" "backup_lifecycle" {
  storage_account_id = azurerm_storage_account.backup_storage.id

  rule {
    name    = "backup-lifecycle-rule"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
      }

      version {
        delete_after_days_since_creation = 365
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 365
      }
    }
  }
}

# Azure AD Application for CI/CD
resource "azuread_application" "backup_app" {
  display_name = "${var.project_name}-backup-app"

  tags = [var.environment, var.project_name, "backup", "ci"]
}

# Service Principal for the application
resource "azuread_service_principal" "backup_sp" {
  client_id = azuread_application.backup_app.client_id

  tags = [var.environment, var.project_name, "backup", "ci"]
}

# Service Principal password/secret
resource "azuread_service_principal_password" "backup_sp_password" {
  service_principal_id = azuread_service_principal.backup_sp.id
  end_date             = timeadd(timestamp(), "8760h") # 1 year
}

# Role assignment: Storage Blob Data Contributor on container
resource "azurerm_role_assignment" "sp_blob_contributor" {
  scope                = azurerm_storage_account.backup_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.backup_sp.object_id
}
