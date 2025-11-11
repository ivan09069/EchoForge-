#!/bin/bash
# EchoForge Azure Backup Script
# Archives the current repository and uploads to Azure Blob Storage

set -euo pipefail

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="echoforge-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Required environment variables
: "${AZURE_STORAGE_ACCOUNT:?AZURE_STORAGE_ACCOUNT must be set}"
: "${AZURE_STORAGE_CONTAINER:?AZURE_STORAGE_CONTAINER must be set}"

# Cleanup function
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "========================================="
echo "EchoForge Azure Backup"
echo "========================================="
echo "Timestamp: ${TIMESTAMP}"
echo "Storage Account: ${AZURE_STORAGE_ACCOUNT}"
echo "Container: ${AZURE_STORAGE_CONTAINER}"
echo "========================================="

# Create git archive of current HEAD
echo "Creating repository archive..."
git archive --format=tar.gz --prefix=echoforge/ HEAD > "${TEMP_DIR}/${BACKUP_FILENAME}"

# Get archive size for reporting
ARCHIVE_SIZE=$(du -h "${TEMP_DIR}/${BACKUP_FILENAME}" | cut -f1)
echo "Archive created: ${BACKUP_FILENAME} (${ARCHIVE_SIZE})"

# Upload to Azure Blob Storage
echo "Uploading to Azure Blob Storage..."
az storage blob upload \
  --account-name "${AZURE_STORAGE_ACCOUNT}" \
  --container-name "${AZURE_STORAGE_CONTAINER}" \
  --name "${BACKUP_FILENAME}" \
  --file "${TEMP_DIR}/${BACKUP_FILENAME}" \
  --no-progress

echo "========================================="
echo "Backup completed successfully!"
echo "Azure URI: https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_STORAGE_CONTAINER}/${BACKUP_FILENAME}"
echo "========================================="
