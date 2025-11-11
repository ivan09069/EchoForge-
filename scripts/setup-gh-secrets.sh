#!/bin/bash
# EchoForge GitHub Secrets Setup Script
# Reads Terraform outputs and configures GitHub Actions secrets for AWS, Azure, and GCP

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_TERRAFORM_DIR="${AWS_TERRAFORM_DIR:-./infra/aws/terraform}"
AZURE_TERRAFORM_DIR="${AZURE_TERRAFORM_DIR:-./infra/azure/terraform}"
GCP_TERRAFORM_DIR="${GCP_TERRAFORM_DIR:-./infra/gcp/terraform}"
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-}"
REPO_NAME="${GITHUB_REPOSITORY_NAME:-}"

echo "========================================="
echo "EchoForge GitHub Secrets Setup"
echo "Multi-Cloud Configuration"
echo "========================================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
  echo "Install from: https://cli.github.com/"
  exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
  echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
  echo "Run: gh auth login"
  exit 1
fi

# Determine repository
if [ -z "${REPO_OWNER}" ] || [ -z "${REPO_NAME}" ]; then
  # Try to get from git remote
  GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "${GIT_REMOTE}" ]; then
    # Extract owner/repo from git remote URL
    if [[ "${GIT_REMOTE}" =~ github\.com[:/]([^/]+)/([^/\.]+) ]]; then
      REPO_OWNER="${BASH_REMATCH[1]}"
      REPO_NAME="${BASH_REMATCH[2]}"
    fi
  fi
fi

if [ -z "${REPO_OWNER}" ] || [ -z "${REPO_NAME}" ]; then
  echo -e "${RED}Error: Could not determine repository${NC}"
  echo "Set GITHUB_REPOSITORY_OWNER and GITHUB_REPOSITORY_NAME environment variables"
  exit 1
fi

REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
echo "Repository: ${REPO_FULL}"
echo ""

# Function to set GitHub secret
set_secret() {
  local secret_name=$1
  local secret_value=$2
  gh secret set "${secret_name}" --body "${secret_value}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set ${secret_name}${NC}"
}

# AWS Configuration
echo -e "${BLUE}=== AWS Configuration ===${NC}"
if [ -d "${AWS_TERRAFORM_DIR}" ] && [ -f "${AWS_TERRAFORM_DIR}/terraform.tfstate" ]; then
  echo "Reading AWS Terraform outputs..."
  cd "${AWS_TERRAFORM_DIR}"
  
  BUCKET_NAME=$(terraform output -raw backup_bucket_name 2>/dev/null)
  AWS_REGION=$(terraform output -raw aws_region 2>/dev/null)
  AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id 2>/dev/null)
  AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key 2>/dev/null)
  
  if [ -n "${BUCKET_NAME}" ] && [ -n "${AWS_REGION}" ] && [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo -e "${GREEN}✓ AWS Terraform outputs retrieved${NC}"
    cd - > /dev/null
    
    set_secret "AWS_REGION" "${AWS_REGION}"
    set_secret "AWS_ACCESS_KEY_ID" "${AWS_ACCESS_KEY_ID}"
    set_secret "AWS_SECRET_ACCESS_KEY" "${AWS_SECRET_ACCESS_KEY}"
    set_secret "AWS_BACKUP_BUCKET" "${BUCKET_NAME}"
    # Legacy name for backward compatibility
    set_secret "BACKUP_BUCKET" "${BUCKET_NAME}"
    echo ""
  else
    echo -e "${YELLOW}⚠ AWS Terraform outputs incomplete or missing${NC}"
    cd - > /dev/null
  fi
else
  echo -e "${YELLOW}⚠ AWS Terraform not found or not applied${NC}"
  echo "  Directory: ${AWS_TERRAFORM_DIR}"
fi
echo ""

# Azure Configuration
echo -e "${BLUE}=== Azure Configuration ===${NC}"
if [ -d "${AZURE_TERRAFORM_DIR}" ] && [ -f "${AZURE_TERRAFORM_DIR}/terraform.tfstate" ]; then
  echo "Reading Azure Terraform outputs..."
  cd "${AZURE_TERRAFORM_DIR}"
  
  AZURE_STORAGE_ACCOUNT=$(terraform output -raw storage_account_name 2>/dev/null)
  AZURE_STORAGE_CONTAINER=$(terraform output -raw container_name 2>/dev/null)
  AZURE_CREDENTIALS=$(terraform output -raw azure_credentials_json 2>/dev/null)
  
  if [ -n "${AZURE_STORAGE_ACCOUNT}" ] && [ -n "${AZURE_STORAGE_CONTAINER}" ] && [ -n "${AZURE_CREDENTIALS}" ]; then
    echo -e "${GREEN}✓ Azure Terraform outputs retrieved${NC}"
    cd - > /dev/null
    
    set_secret "AZURE_CREDENTIALS" "${AZURE_CREDENTIALS}"
    set_secret "AZURE_STORAGE_ACCOUNT" "${AZURE_STORAGE_ACCOUNT}"
    set_secret "AZURE_STORAGE_CONTAINER" "${AZURE_STORAGE_CONTAINER}"
    echo ""
  else
    echo -e "${YELLOW}⚠ Azure Terraform outputs incomplete or missing${NC}"
    cd - > /dev/null
  fi
else
  echo -e "${YELLOW}⚠ Azure Terraform not found or not applied${NC}"
  echo "  Directory: ${AZURE_TERRAFORM_DIR}"
fi
echo ""

# GCP Configuration
echo -e "${BLUE}=== GCP Configuration ===${NC}"
if [ -d "${GCP_TERRAFORM_DIR}" ] && [ -f "${GCP_TERRAFORM_DIR}/terraform.tfstate" ]; then
  echo "Reading GCP Terraform outputs..."
  cd "${GCP_TERRAFORM_DIR}"
  
  GCP_PROJECT_ID=$(terraform output -raw project_id 2>/dev/null)
  GCS_BUCKET=$(terraform output -raw bucket_name 2>/dev/null)
  GCP_SA_KEY=$(terraform output -raw service_account_key 2>/dev/null)
  
  if [ -n "${GCP_PROJECT_ID}" ] && [ -n "${GCS_BUCKET}" ] && [ -n "${GCP_SA_KEY}" ]; then
    echo -e "${GREEN}✓ GCP Terraform outputs retrieved${NC}"
    cd - > /dev/null
    
    set_secret "GCP_SA_KEY" "${GCP_SA_KEY}"
    set_secret "GCP_PROJECT_ID" "${GCP_PROJECT_ID}"
    set_secret "GCS_BUCKET" "${GCS_BUCKET}"
    echo ""
  else
    echo -e "${YELLOW}⚠ GCP Terraform outputs incomplete or missing${NC}"
    cd - > /dev/null
  fi
else
  echo -e "${YELLOW}⚠ GCP Terraform not found or not applied${NC}"
  echo "  Directory: ${GCP_TERRAFORM_DIR}"
fi
echo ""

echo "========================================="
echo -e "${GREEN}GitHub secrets configuration completed!${NC}"
echo "========================================="
echo ""
echo "Configured secrets:"
gh secret list --repo "${REPO_FULL}" | grep -E "AWS_|AZURE_|GCP_|GCS_|BACKUP_" || echo "  (none found matching AWS/AZURE/GCP patterns)"
echo ""
echo -e "${YELLOW}Optional: Set SLACK_WEBHOOK_URL for notifications${NC}"
echo "Run: gh secret set SLACK_WEBHOOK_URL --repo ${REPO_FULL}"
echo ""
echo "Next steps:"
echo "  1. Verify secrets: gh secret list --repo ${REPO_FULL}"
echo "  2. Test backup workflow:"
echo "     AWS:   gh workflow run self-heal-agent.yml --field backup_source=aws --field operation=backup --repo ${REPO_FULL}"
echo "     Azure: gh workflow run self-heal-agent.yml --field backup_source=azure --field operation=backup --repo ${REPO_FULL}"
echo "     GCP:   gh workflow run self-heal-agent.yml --field backup_source=gcp --field operation=backup --repo ${REPO_FULL}"
