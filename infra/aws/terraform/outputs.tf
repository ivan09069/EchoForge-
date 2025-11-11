# Terraform outputs for EchoForge backup infrastructure
# Exports resource identifiers and credentials for use in GitHub Actions

output "backup_bucket_name" {
  description = "Name of the S3 backup bucket"
  value       = aws_s3_bucket.backup_bucket.id
}

output "backup_bucket_arn" {
  description = "ARN of the S3 backup bucket"
  value       = aws_s3_bucket.backup_bucket.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for backup encryption"
  value       = aws_kms_key.backup_key.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for backup encryption"
  value       = aws_kms_key.backup_key.arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = aws_kms_alias.backup_key_alias.name
}

output "backup_user_name" {
  description = "Name of the IAM user for backup operations"
  value       = aws_iam_user.backup_user.name
}

output "backup_user_arn" {
  description = "ARN of the IAM user for backup operations"
  value       = aws_iam_user.backup_user.arn
}

output "aws_access_key_id" {
  description = "AWS Access Key ID for backup user (sensitive)"
  value       = aws_iam_access_key.backup_user_key.id
  sensitive   = true
}

output "aws_secret_access_key" {
  description = "AWS Secret Access Key for backup user (sensitive)"
  value       = aws_iam_access_key.backup_user_key.secret
  sensitive   = true
}

output "aws_region" {
  description = "AWS region where resources are created"
  value       = var.aws_region
}
