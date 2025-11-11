# Main Terraform configuration for EchoForge GCP backup infrastructure
# Creates Cloud Storage bucket, KMS key, and Service Account with least-privilege access

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Data source for current project
data "google_project" "current" {
  project_id = var.gcp_project_id
}

# KMS Key Ring for encryption keys
resource "google_kms_key_ring" "backup_keyring" {
  name     = "${var.project_name}-backup-keyring"
  location = var.gcp_region
}

# KMS Crypto Key for bucket encryption
resource "google_kms_crypto_key" "backup_key" {
  name     = "${var.project_name}-backup-key"
  key_ring = google_kms_key_ring.backup_keyring.id

  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false
  }

  labels = {
    name        = "${var.project_name}-backup-key"
    environment = var.environment
    project     = var.project_name
  }
}

# Cloud Storage bucket for backups
# Configured with versioning, encryption, and lifecycle rules
resource "google_storage_bucket" "backup_bucket" {
  name     = var.bucket_name
  location = var.gcp_region
  project  = var.gcp_project_id

  # Storage class
  storage_class = "STANDARD"

  # Uniform bucket-level access (recommended)
  uniform_bucket_level_access = true

  # Versioning for data protection
  versioning {
    enabled = true
  }

  # Encryption with customer-managed key
  encryption {
    default_kms_key_name = google_kms_crypto_key.backup_key.id
  }

  # Lifecycle rules for cost optimization
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  # Public access prevention
  public_access_prevention = "enforced"

  labels = {
    name        = "${var.project_name}-backup-bucket"
    environment = var.environment
    project     = var.project_name
  }
}

# Service Account for backup operations
resource "google_service_account" "backup_sa" {
  account_id   = "${var.project_name}-backup-sa"
  display_name = "EchoForge Backup Service Account"
  description  = "Service account for backup operations with least-privilege access"
  project      = var.gcp_project_id
}

# Service Account Key
resource "google_service_account_key" "backup_sa_key" {
  service_account_id = google_service_account.backup_sa.name
}

# IAM binding: Storage Object Admin on the bucket
# Provides least-privilege access for backup operations
resource "google_storage_bucket_iam_member" "backup_sa_object_admin" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backup_sa.email}"
}

# IAM binding: Storage Legacy Bucket Reader
# Required for listing bucket contents
resource "google_storage_bucket_iam_member" "backup_sa_bucket_reader" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.backup_sa.email}"
}

# IAM binding: Cloud KMS CryptoKey Encrypter/Decrypter
# Required for using the KMS key
resource "google_kms_crypto_key_iam_member" "backup_sa_kms" {
  crypto_key_id = google_kms_crypto_key.backup_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.backup_sa.email}"
}

# Grant Cloud Storage service account access to KMS key
resource "google_kms_crypto_key_iam_member" "gcs_kms" {
  crypto_key_id = google_kms_crypto_key.backup_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Enable required APIs (if not already enabled)
resource "google_project_service" "storage_api" {
  project = var.gcp_project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "kms_api" {
  project = var.gcp_project_id
  service = "cloudkms.googleapis.com"

  disable_on_destroy = false
}
