#!/bin/bash
# EchoForge GCP Backup Script
# Archives the current repository and uploads to Google Cloud Storage

set -euo pipefail

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="echoforge-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Required environment variables
: "${GCS_BUCKET:?GCS_BUCKET must be set}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID must be set}"

# Cleanup function
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "========================================="
echo "EchoForge GCP Backup"
echo "========================================="
echo "Timestamp: ${TIMESTAMP}"
echo "Bucket: ${GCS_BUCKET}"
echo "Project: ${GCP_PROJECT_ID}"
echo "========================================="

# Create git archive of current HEAD
echo "Creating repository archive..."
git archive --format=tar.gz --prefix=echoforge/ HEAD > "${TEMP_DIR}/${BACKUP_FILENAME}"

# Get archive size for reporting
ARCHIVE_SIZE=$(du -h "${TEMP_DIR}/${BACKUP_FILENAME}" | cut -f1)
echo "Archive created: ${BACKUP_FILENAME} (${ARCHIVE_SIZE})"

# Upload to Google Cloud Storage
echo "Uploading to Google Cloud Storage..."
gsutil cp "${TEMP_DIR}/${BACKUP_FILENAME}" "gs://${GCS_BUCKET}/${BACKUP_FILENAME}"

echo "========================================="
echo "Backup completed successfully!"
echo "GCS URI: gs://${GCS_BUCKET}/${BACKUP_FILENAME}"
echo "========================================="
