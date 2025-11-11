#!/bin/bash
# EchoForge AWS Backup Script
# Archives the current repository and uploads to S3

set -euo pipefail

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="echoforge-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Required environment variables
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set}"
: "${AWS_REGION:?AWS_REGION must be set}"
: "${BACKUP_BUCKET:?BACKUP_BUCKET must be set}"

# Cleanup function
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "========================================="
echo "EchoForge AWS Backup"
echo "========================================="
echo "Timestamp: ${TIMESTAMP}"
echo "Bucket: ${BACKUP_BUCKET}"
echo "Region: ${AWS_REGION}"
echo "========================================="

# Create git archive of current HEAD
echo "Creating repository archive..."
git archive --format=tar.gz --prefix=echoforge/ HEAD > "${TEMP_DIR}/${BACKUP_FILENAME}"

# Get archive size for reporting
ARCHIVE_SIZE=$(du -h "${TEMP_DIR}/${BACKUP_FILENAME}" | cut -f1)
echo "Archive created: ${BACKUP_FILENAME} (${ARCHIVE_SIZE})"

# Upload to S3
echo "Uploading to S3..."
aws s3 cp "${TEMP_DIR}/${BACKUP_FILENAME}" "s3://${BACKUP_BUCKET}/${BACKUP_FILENAME}" \
  --region "${AWS_REGION}" \
  --no-progress

echo "========================================="
echo "Backup completed successfully!"
echo "S3 URI: s3://${BACKUP_BUCKET}/${BACKUP_FILENAME}"
echo "========================================="
