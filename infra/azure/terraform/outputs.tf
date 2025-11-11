# Terraform outputs for EchoForge Azure backup infrastructure
# Exports resource identifiers and credentials for use in GitHub Actions

output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.backup_kv.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.backup_kv.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.backup_storage.name
}

output "storage_account_id" {
  description = "ID of the Storage Account"
  value       = azurerm_storage_account.backup_storage.id
}

output "container_name" {
  description = "Name of the backup container"
  value       = azurerm_storage_container.backup_container.name
}

output "application_id" {
  description = "Application (client) ID of the Azure AD app"
  value       = azuread_application.backup_app.client_id
}

output "service_principal_id" {
  description = "Object ID of the service principal"
  value       = azuread_service_principal.backup_sp.object_id
}

output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}

output "client_secret" {
  description = "Service principal client secret (sensitive)"
  value       = azuread_service_principal_password.backup_sp_password.value
  sensitive   = true
}

output "azure_credentials_json" {
  description = "JSON credentials for GitHub Actions azure/login (sensitive)"
  value = jsonencode({
    clientId       = azuread_application.backup_app.client_id
    clientSecret   = azuread_service_principal_password.backup_sp_password.value
    subscriptionId = data.azurerm_client_config.current.subscription_id
    tenantId       = data.azurerm_client_config.current.tenant_id
  })
  sensitive = true
}
