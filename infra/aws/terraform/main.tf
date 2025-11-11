# Main Terraform configuration for EchoForge backup infrastructure
# Creates S3 bucket, KMS key, IAM user with least-privilege access

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# KMS key for S3 bucket encryption
# Provides encryption at rest for backup data
resource "aws_kms_key" "backup_key" {
  description             = "KMS key for EchoForge backup encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-backup-kms-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

# KMS key alias for easier reference
resource "aws_kms_alias" "backup_key_alias" {
  name          = "alias/${var.project_name}-backup-key"
  target_key_id = aws_kms_key.backup_key.key_id
}

# S3 bucket for backups with security features
# Private, versioned, encrypted with SSE-KMS
resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.project_name}-backup-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "backup_bucket_public_access" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning to protect against accidental deletions
resource "aws_s3_bucket_versioning" "backup_bucket_versioning" {
  bucket = aws_s3_bucket.backup_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket_encryption" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.backup_key.arn
    }
    bucket_key_enabled = true
  }
}

# Lifecycle rules for cost optimization
# STANDARD_IA after 30 days, GLACIER after 90 days, expire noncurrent versions after 365 days
resource "aws_s3_bucket_lifecycle_configuration" "backup_bucket_lifecycle" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# IAM user for backup operations with least-privilege access
resource "aws_iam_user" "backup_user" {
  name = "${var.project_name}-backup-user"

  tags = {
    Name        = "${var.project_name}-backup-user"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Access key for the backup user
resource "aws_iam_access_key" "backup_user_key" {
  user = aws_iam_user.backup_user.name
}

# IAM policy with least-privilege permissions
# Allows only necessary S3 and KMS operations
resource "aws_iam_user_policy" "backup_user_policy" {
  name = "${var.project_name}-backup-policy"
  user = aws_iam_user.backup_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BackupOperations"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.backup_bucket.arn,
          "${aws_s3_bucket.backup_bucket.arn}/*"
        ]
      },
      {
        Sid    = "KMSEncryptDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.backup_key.arn
      }
    ]
  })
}
