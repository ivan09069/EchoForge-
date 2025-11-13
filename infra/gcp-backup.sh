#!/bin/bash
# EchoForge GCP Backup Script
# Archives the current repository and uploads to Google Cloud Storage
# Creates and uploads backup to Google Cloud Storage

set -euo pipefail

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="echoforge-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Required environment variables
: "${GCS_BUCKET:?GCS_BUCKET must be set}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID must be set}"
# GCP configuration from environment
GCP_BUCKET_NAME="${GCP_BUCKET_NAME:-}"
GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-}"

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
echo "Bucket: ${GCP_BUCKET_NAME}"
echo "========================================="

# Validate required environment variables
if [ -z "${GCP_BUCKET_NAME}" ]; then
  echo "Error: Missing required environment variable: GCP_BUCKET_NAME"
  exit 1
fi

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
# Generate checksum
echo "Generating checksum..."
CHECKSUM=$(openssl sha256 "${TEMP_DIR}/${BACKUP_FILENAME}" | awk '{print $2}')
echo "${CHECKSUM}" > "${TEMP_DIR}/${BACKUP_FILENAME}.sha256"
echo "Checksum: ${CHECKSUM}"

# Upload to Google Cloud Storage
echo ""
echo "Uploading to Google Cloud Storage..."

# Check if gsutil is available
if command -v gsutil &> /dev/null; then
  # Use gsutil
  gsutil cp "${TEMP_DIR}/${BACKUP_FILENAME}" "gs://${GCP_BUCKET_NAME}/${BACKUP_FILENAME}"
  gsutil cp "${TEMP_DIR}/${BACKUP_FILENAME}.sha256" "gs://${GCP_BUCKET_NAME}/${BACKUP_FILENAME}.sha256"
elif command -v gcloud &> /dev/null; then
  # Use gcloud storage
  gcloud storage cp "${TEMP_DIR}/${BACKUP_FILENAME}" "gs://${GCP_BUCKET_NAME}/${BACKUP_FILENAME}"
  gcloud storage cp "${TEMP_DIR}/${BACKUP_FILENAME}.sha256" "gs://${GCP_BUCKET_NAME}/${BACKUP_FILENAME}.sha256"
else
  echo "Error: Neither gsutil nor gcloud is available"
  echo "Please install Google Cloud SDK"
  exit 1
fi

echo ""
echo "========================================="
echo "✓ Backup completed successfully"
echo "========================================="
echo "File: ${BACKUP_FILENAME}"
echo "Size: ${ARCHIVE_SIZE}"
echo "Checksum: ${CHECKSUM}"
echo "Location: Google Cloud Storage"
echo "Bucket: ${GCP_BUCKET_NAME}"
echo "========================================="

exit 0
