# Terraform outputs for EchoForge GCP backup infrastructure
# Exports resource identifiers and credentials for use in GitHub Actions

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "bucket_name" {
  description = "Name of the GCS backup bucket"
output "bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.backup_bucket.name
}

output "bucket_url" {
  description = "URL of the GCS backup bucket"
  value       = google_storage_bucket.backup_bucket.url
}

output "keyring_name" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.backup_bucket.url
}

output "kms_key_ring_name" {
  description = "Name of the KMS key ring"
  value       = google_kms_key_ring.backup_keyring.name
}

output "key_name" {
output "kms_crypto_key_name" {
  description = "Name of the KMS crypto key"
  value       = google_kms_crypto_key.backup_key.name
}

output "kms_crypto_key_id" {
  description = "ID of the KMS crypto key"
  value       = google_kms_crypto_key.backup_key.id
}

output "service_account_email" {
  description = "Email of the backup service account"
  value       = google_service_account.backup_sa.email
}

output "service_account_id" {
  description = "ID of the backup service account"
  value       = google_service_account.backup_sa.id
}

output "service_account_key" {
  description = "Service account key JSON for GitHub Actions (sensitive)"
  value       = base64decode(google_service_account_key.backup_sa_key.private_key)
  sensitive   = true
}
output "service_account_key" {
  description = "Service account key in JSON format (base64 encoded, sensitive)"
  value       = google_service_account_key.backup_sa_key.private_key
  sensitive   = true
}

output "gcp_project_id" {
  description = "GCP Project ID"
  value       = var.gcp_project_id
}

output "gcp_region" {
  description = "GCP region where resources are created"
  value       = var.gcp_region
}
