#!/bin/bash
# EchoForge GitHub Secrets Setup Script
# Reads Terraform outputs and configures GitHub Actions secrets

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_DIR="${TERRAFORM_DIR:-./infra/aws/terraform}"
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-}"
REPO_NAME="${GITHUB_REPOSITORY_NAME:-}"

echo "========================================="
echo "EchoForge GitHub Secrets Setup"
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

# Check if Terraform directory exists
if [ ! -d "${TERRAFORM_DIR}" ]; then
  echo -e "${RED}Error: Terraform directory not found: ${TERRAFORM_DIR}${NC}"
  exit 1
fi

# Check if Terraform has been applied
if [ ! -f "${TERRAFORM_DIR}/terraform.tfstate" ]; then
  echo -e "${RED}Error: Terraform state not found${NC}"
  echo "Run 'terraform apply' in ${TERRAFORM_DIR} first"
  exit 1
fi

echo "Reading Terraform outputs..."
cd "${TERRAFORM_DIR}"

# Extract outputs using terraform output
BUCKET_NAME=$(terraform output -raw backup_bucket_name 2>/dev/null)
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null)
AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id 2>/dev/null)
AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key 2>/dev/null)

# Validate outputs
if [ -z "${BUCKET_NAME}" ] || [ -z "${AWS_REGION}" ] || [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo -e "${RED}Error: Failed to read Terraform outputs${NC}"
  echo "Ensure Terraform has been applied successfully"
  exit 1
fi

echo -e "${GREEN}✓ Terraform outputs retrieved${NC}"
echo ""

# Set GitHub secrets
echo "Setting GitHub Actions secrets..."

gh secret set AWS_REGION --body "${AWS_REGION}" --repo "${REPO_FULL}"
echo -e "${GREEN}✓ Set AWS_REGION${NC}"

gh secret set AWS_ACCESS_KEY_ID --body "${AWS_ACCESS_KEY_ID}" --repo "${REPO_FULL}"
echo -e "${GREEN}✓ Set AWS_ACCESS_KEY_ID${NC}"

gh secret set AWS_SECRET_ACCESS_KEY --body "${AWS_SECRET_ACCESS_KEY}" --repo "${REPO_FULL}"
echo -e "${GREEN}✓ Set AWS_SECRET_ACCESS_KEY${NC}"

gh secret set BACKUP_BUCKET --body "${BUCKET_NAME}" --repo "${REPO_FULL}"
echo -e "${GREEN}✓ Set BACKUP_BUCKET${NC}"

echo ""
echo "========================================="
echo -e "${GREEN}GitHub secrets configured successfully!${NC}"
echo "========================================="
echo ""
echo "Configured secrets:"
echo "  - AWS_REGION"
echo "  - AWS_ACCESS_KEY_ID"
echo "  - AWS_SECRET_ACCESS_KEY"
echo "  - BACKUP_BUCKET"
echo ""
echo -e "${YELLOW}Optional: Set SLACK_WEBHOOK_URL for notifications${NC}"
echo "Run: gh secret set SLACK_WEBHOOK_URL --repo ${REPO_FULL}"
echo ""
echo "Next steps:"
echo "  1. Verify secrets: gh secret list --repo ${REPO_FULL}"
echo "  2. Test backup workflow: gh workflow run self-heal-agent.yml --repo ${REPO_FULL}"
