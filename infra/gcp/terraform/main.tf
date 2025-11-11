# Main Terraform configuration for EchoForge GCP backup infrastructure
# Creates KMS key, GCS bucket with CMEK encryption, and service account

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
  project = var.project_id
  region  = var.region
}

# KMS key ring for encryption keys
resource "google_kms_key_ring" "backup_keyring" {
  name     = var.keyring_name
  location = var.region
}

# KMS crypto key for bucket encryption
resource "google_kms_crypto_key" "backup_key" {
  name            = var.key_name
  key_ring        = google_kms_key_ring.backup_keyring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false
  }

  labels = {
    environment = var.environment
    project     = var.project_name
  }
}

# Service Account for backup operations
resource "google_service_account" "backup_sa" {
  account_id   = var.service_account_id
  display_name = "${var.project_name} Backup Service Account"
  description  = "Service account for EchoForge backup operations with least-privilege access"
}

# GCS bucket with CMEK encryption and versioning
resource "google_storage_bucket" "backup_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.backup_key.id
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 30
    }
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      age = 90
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions         = 0
      days_since_noncurrent_time = 365
    }
  }

  labels = {
    environment = var.environment
    project     = var.project_name
  }

  depends_on = [
    google_kms_crypto_key_iam_member.bucket_kms_binding
  ]
}

# IAM binding for service account to access bucket
# Grant Storage Object Admin role (least privilege for upload/download)
resource "google_storage_bucket_iam_member" "backup_sa_object_admin" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backup_sa.email}"
}

# IAM binding for service account to use KMS key
# Grant Cloud KMS CryptoKey Encrypter/Decrypter role
resource "google_kms_crypto_key_iam_member" "backup_sa_kms" {
  crypto_key_id = google_kms_crypto_key.backup_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.backup_sa.email}"
}

# IAM binding for GCS service account to use KMS key for encryption
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_member" "bucket_kms_binding" {
  crypto_key_id = google_kms_crypto_key.backup_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

# Service account key for GitHub Actions authentication
resource "google_service_account_key" "backup_sa_key" {
  service_account_id = google_service_account.backup_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
