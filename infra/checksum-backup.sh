#!/bin/bash
# EchoForge Backup Integrity Checker
# Generates and validates checksums for backup files to ensure data integrity

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHECKSUM_ALGO="${CHECKSUM_ALGO:-sha256}"

# Usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") <command> <backup-file>

Commands:
  generate    Generate checksum file for backup
  verify      Verify backup against checksum file
  both        Generate backup and checksum together

Arguments:
  backup-file Path to the backup file (tar.gz)

Environment Variables:
  CHECKSUM_ALGO   Hash algorithm to use (default: sha256)
                  Options: md5, sha1, sha256, sha512

Examples:
  $(basename "$0") generate backup.tar.gz
  $(basename "$0") verify backup.tar.gz
  $(basename "$0") both backup.tar.gz

EOF
  exit 1
}

# Check if required tools are available
check_dependencies() {
  local missing_deps=()
  
  for cmd in openssl tar; do
    if ! command -v "$cmd" &> /dev/null; then
      missing_deps+=("$cmd")
    fi
  done
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}Error: Missing required dependencies: ${missing_deps[*]}${NC}"
    exit 1
  fi
}

# Generate checksum for a file
generate_checksum() {
  local file="$1"
  local checksum_file="${file}.${CHECKSUM_ALGO}"
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}Error: File not found: ${file}${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}Generating ${CHECKSUM_ALGO} checksum for: ${file}${NC}"
  
  # Generate checksum based on algorithm
  case "$CHECKSUM_ALGO" in
    md5)
      openssl md5 "$file" | awk '{print $2}' > "$checksum_file"
      ;;
    sha1)
      openssl sha1 "$file" | awk '{print $2}' > "$checksum_file"
      ;;
    sha256)
      openssl sha256 "$file" | awk '{print $2}' > "$checksum_file"
      ;;
    sha512)
      openssl sha512 "$file" | awk '{print $2}' > "$checksum_file"
      ;;
    *)
      echo -e "${RED}Error: Unsupported algorithm: ${CHECKSUM_ALGO}${NC}"
      exit 1
      ;;
  esac
  
  # Store file size for additional validation
  local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
  echo "$file_size" > "${file}.size"
  
  # Store timestamp
  date -u +"%Y-%m-%d %H:%M:%S UTC" > "${file}.timestamp"
  
  echo -e "${GREEN}✓ Checksum generated: ${checksum_file}${NC}"
  echo -e "${GREEN}✓ Size recorded: ${file}.size (${file_size} bytes)${NC}"
  echo -e "${GREEN}✓ Timestamp recorded: ${file}.timestamp${NC}"
  
  # Display checksum for logging
  echo ""
  echo "Checksum details:"
  echo "  File: $(basename "$file")"
  echo "  Size: ${file_size} bytes"
  echo "  Algorithm: ${CHECKSUM_ALGO}"
  echo "  Hash: $(cat "$checksum_file")"
  echo "  Generated: $(cat "${file}.timestamp")"
}

# Verify checksum of a file
verify_checksum() {
  local file="$1"
  local checksum_file="${file}.${CHECKSUM_ALGO}"
  local size_file="${file}.size"
  local timestamp_file="${file}.timestamp"
  
  if [ ! -f "$file" ]; then
    echo -e "${RED}Error: File not found: ${file}${NC}"
    exit 1
  fi
  
  if [ ! -f "$checksum_file" ]; then
    echo -e "${RED}Error: Checksum file not found: ${checksum_file}${NC}"
    echo "Run with 'generate' command first"
    exit 1
  fi
  
  echo -e "${BLUE}Verifying ${CHECKSUM_ALGO} checksum for: ${file}${NC}"
  
  # Read stored checksum
  local stored_checksum=$(cat "$checksum_file")
  
  # Calculate current checksum
  local current_checksum=""
  case "$CHECKSUM_ALGO" in
    md5)
      current_checksum=$(openssl md5 "$file" | awk '{print $2}')
      ;;
    sha1)
      current_checksum=$(openssl sha1 "$file" | awk '{print $2}')
      ;;
    sha256)
      current_checksum=$(openssl sha256 "$file" | awk '{print $2}')
      ;;
    sha512)
      current_checksum=$(openssl sha512 "$file" | awk '{print $2}')
      ;;
    *)
      echo -e "${RED}Error: Unsupported algorithm: ${CHECKSUM_ALGO}${NC}"
      exit 1
      ;;
  esac
  
  # Verify file size
  local stored_size=""
  local current_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
  if [ -f "$size_file" ]; then
    stored_size=$(cat "$size_file")
  fi
  
  # Display verification details
  echo ""
  echo "Verification details:"
  echo "  File: $(basename "$file")"
  echo "  Current size: ${current_size} bytes"
  if [ -n "$stored_size" ]; then
    echo "  Stored size: ${stored_size} bytes"
  fi
  echo "  Algorithm: ${CHECKSUM_ALGO}"
  echo "  Stored hash: ${stored_checksum}"
  echo "  Current hash: ${current_checksum}"
  if [ -f "$timestamp_file" ]; then
    echo "  Checksum generated: $(cat "$timestamp_file")"
  fi
  echo ""
  
  # Verify size match
  if [ -n "$stored_size" ] && [ "$stored_size" != "$current_size" ]; then
    echo -e "${RED}✗ Size verification FAILED${NC}"
    echo -e "${RED}  Expected: ${stored_size} bytes${NC}"
    echo -e "${RED}  Got: ${current_size} bytes${NC}"
    exit 1
  fi
  
  # Verify checksum match
  if [ "$stored_checksum" = "$current_checksum" ]; then
    echo -e "${GREEN}✓ Checksum verification PASSED${NC}"
    echo -e "${GREEN}✓ Backup integrity confirmed${NC}"
    
    # Additional validation: verify tar archive integrity
    echo ""
    echo "Validating archive structure..."
    if tar -tzf "$file" > /dev/null 2>&1; then
      echo -e "${GREEN}✓ Archive structure validation PASSED${NC}"
    else
      echo -e "${YELLOW}⚠ Archive structure validation FAILED${NC}"
      echo -e "${YELLOW}  Warning: Archive may be corrupted${NC}"
      exit 1
    fi
    
    return 0
  else
    echo -e "${RED}✗ Checksum verification FAILED${NC}"
    echo -e "${RED}  File may be corrupted or tampered${NC}"
    exit 1
  fi
}

# Generate backup with checksum
generate_with_checksum() {
  local file="$1"
  
  if [ -f "$file" ]; then
    echo -e "${BLUE}Backup file already exists: ${file}${NC}"
  else
    echo -e "${RED}Error: Backup file not found: ${file}${NC}"
    echo "Create the backup file first"
    exit 1
  fi
  
  generate_checksum "$file"
}

# Main execution
main() {
  if [ $# -lt 2 ]; then
    usage
  fi
  
  check_dependencies
  
  local command="$1"
  local backup_file="$2"
  
  case "$command" in
    generate)
      generate_checksum "$backup_file"
      ;;
    verify)
      verify_checksum "$backup_file"
      ;;
    both)
      generate_with_checksum "$backup_file"
      ;;
    *)
      echo -e "${RED}Error: Unknown command: ${command}${NC}"
      usage
      ;;
  esac
}

# Run main function
main "$@"
