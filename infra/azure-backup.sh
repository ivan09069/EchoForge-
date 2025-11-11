#!/bin/bash
# EchoForge Azure Backup Script
# Creates and uploads backup to Azure Blob Storage

set -euo pipefail

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="echoforge-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Azure configuration from environment
AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT:-}"
AZURE_STORAGE_KEY="${AZURE_STORAGE_KEY:-}"
AZURE_CONTAINER_NAME="${AZURE_CONTAINER_NAME:-backups}"

# Cleanup function
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo "========================================="
echo "EchoForge Azure Backup"
echo "========================================="
echo "Timestamp: ${TIMESTAMP}"
echo "Container: ${AZURE_CONTAINER_NAME}"
echo "========================================="

# Validate required environment variables
if [ -z "${AZURE_STORAGE_ACCOUNT}" ] || [ -z "${AZURE_STORAGE_KEY}" ]; then
  echo "Error: Missing required environment variables"
  echo "Required:"
  echo "  - AZURE_STORAGE_ACCOUNT"
  echo "  - AZURE_STORAGE_KEY"
  echo "  - AZURE_CONTAINER_NAME (optional, defaults to 'backups')"
  exit 1
fi

# Create git archive of current HEAD
echo "Creating repository archive..."
git archive --format=tar.gz --prefix=echoforge/ HEAD > "${TEMP_DIR}/${BACKUP_FILENAME}"

# Get archive size for reporting
ARCHIVE_SIZE=$(du -h "${TEMP_DIR}/${BACKUP_FILENAME}" | cut -f1)
echo "Archive created: ${BACKUP_FILENAME} (${ARCHIVE_SIZE})"

# Generate checksum
echo "Generating checksum..."
CHECKSUM=$(openssl sha256 "${TEMP_DIR}/${BACKUP_FILENAME}" | awk '{print $2}')
echo "${CHECKSUM}" > "${TEMP_DIR}/${BACKUP_FILENAME}.sha256"
echo "Checksum: ${CHECKSUM}"

# Upload to Azure Blob Storage using REST API
echo ""
echo "Uploading to Azure Blob Storage..."

# Upload backup file
curl -X PUT \
  -H "x-ms-blob-type: BlockBlob" \
  -H "x-ms-date: $(date -u '+%a, %d %b %Y %H:%M:%S GMT')" \
  -H "x-ms-version: 2021-08-06" \
  -H "Authorization: SharedKey ${AZURE_STORAGE_ACCOUNT}:$(echo -n "PUT\n\n\n$(stat -f%z "${TEMP_DIR}/${BACKUP_FILENAME}" 2>/dev/null || stat -c%s "${TEMP_DIR}/${BACKUP_FILENAME}")\n\napplication/gzip\n\n\n\n\n\nx-ms-blob-type:BlockBlob\nx-ms-date:$(date -u '+%a, %d %b %Y %H:%M:%S GMT')\nx-ms-version:2021-08-06\n/${AZURE_STORAGE_ACCOUNT}/${AZURE_CONTAINER_NAME}/${BACKUP_FILENAME}" | openssl sha256 -hmac "$(echo ${AZURE_STORAGE_KEY} | base64 -d)" -binary | base64)" \
  --data-binary "@${TEMP_DIR}/${BACKUP_FILENAME}" \
  "https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_CONTAINER_NAME}/${BACKUP_FILENAME}" 2>&1 || {
    echo "Warning: Direct upload failed, falling back to az CLI if available"
    
    # Fallback to Azure CLI if available
    if command -v az &> /dev/null; then
      az storage blob upload \
        --account-name "${AZURE_STORAGE_ACCOUNT}" \
        --account-key "${AZURE_STORAGE_KEY}" \
        --container-name "${AZURE_CONTAINER_NAME}" \
        --name "${BACKUP_FILENAME}" \
        --file "${TEMP_DIR}/${BACKUP_FILENAME}" \
        --content-type "application/gzip"
      
      # Upload checksum
      az storage blob upload \
        --account-name "${AZURE_STORAGE_ACCOUNT}" \
        --account-key "${AZURE_STORAGE_KEY}" \
        --container-name "${AZURE_CONTAINER_NAME}" \
        --name "${BACKUP_FILENAME}.sha256" \
        --file "${TEMP_DIR}/${BACKUP_FILENAME}.sha256" \
        --content-type "text/plain"
    else
      echo "Error: Azure CLI not available and direct upload failed"
      exit 1
    fi
  }

echo ""
echo "========================================="
echo "✓ Backup completed successfully"
echo "========================================="
echo "File: ${BACKUP_FILENAME}"
echo "Size: ${ARCHIVE_SIZE}"
echo "Checksum: ${CHECKSUM}"
echo "Location: Azure Blob Storage"
echo "Container: ${AZURE_CONTAINER_NAME}"
echo "========================================="

exit 0
