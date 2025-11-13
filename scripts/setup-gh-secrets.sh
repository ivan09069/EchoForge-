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
TERRAFORM_DIR_AWS="${TERRAFORM_DIR_AWS:-./infra/aws/terraform}"
TERRAFORM_DIR_AZURE="${TERRAFORM_DIR_AZURE:-./infra/azure/terraform}"
TERRAFORM_DIR_GCP="${TERRAFORM_DIR_GCP:-./infra/gcp/terraform}"
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
  
# Function to setup AWS secrets
setup_aws_secrets() {
  echo -e "${BLUE}Setting up AWS secrets...${NC}"
  
  if [ ! -d "${TERRAFORM_DIR_AWS}" ]; then
    echo -e "${YELLOW}⚠ AWS Terraform directory not found: ${TERRAFORM_DIR_AWS}${NC}"
    return 1
  fi
  
  if [ ! -f "${TERRAFORM_DIR_AWS}/terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠ AWS Terraform state not found${NC}"
    echo "Run 'terraform apply' in ${TERRAFORM_DIR_AWS} first"
    return 1
  fi
  
  cd "${TERRAFORM_DIR_AWS}"
  
  # Extract outputs using terraform output
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
  cd - > /dev/null
  
  # Validate outputs
  if [ -z "${BUCKET_NAME}" ] || [ -z "${AWS_REGION}" ] || [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo -e "${RED}Error: Failed to read AWS Terraform outputs${NC}"
    return 1
  fi
  
  # Set GitHub secrets
  gh secret set AWS_REGION --body "${AWS_REGION}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AWS_REGION${NC}"
  
  gh secret set AWS_ACCESS_KEY_ID --body "${AWS_ACCESS_KEY_ID}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AWS_ACCESS_KEY_ID${NC}"
  
  gh secret set AWS_SECRET_ACCESS_KEY --body "${AWS_SECRET_ACCESS_KEY}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AWS_SECRET_ACCESS_KEY${NC}"
  
  gh secret set BACKUP_BUCKET --body "${BUCKET_NAME}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set BACKUP_BUCKET${NC}"
  
  echo -e "${GREEN}✓ AWS secrets configured successfully${NC}"
  echo ""
  return 0
}

# Function to setup Azure secrets
setup_azure_secrets() {
  echo -e "${BLUE}Setting up Azure secrets...${NC}"
  
  if [ ! -d "${TERRAFORM_DIR_AZURE}" ]; then
    echo -e "${YELLOW}⚠ Azure Terraform directory not found: ${TERRAFORM_DIR_AZURE}${NC}"
    return 1
  fi
  
  if [ ! -f "${TERRAFORM_DIR_AZURE}/terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠ Azure Terraform state not found${NC}"
    echo "Run 'terraform apply' in ${TERRAFORM_DIR_AZURE} first"
    return 1
  fi
  
  cd "${TERRAFORM_DIR_AZURE}"
  
  # Extract outputs using terraform output
  STORAGE_ACCOUNT=$(terraform output -raw storage_account_name 2>/dev/null)
  STORAGE_KEY=$(terraform output -raw storage_account_key 2>/dev/null)
  CONTAINER_NAME=$(terraform output -raw container_name 2>/dev/null)
  CLIENT_ID=$(terraform output -raw service_principal_client_id 2>/dev/null)
  CLIENT_SECRET=$(terraform output -raw service_principal_client_secret 2>/dev/null)
  TENANT_ID=$(terraform output -raw tenant_id 2>/dev/null)
  SUBSCRIPTION_ID=$(terraform output -raw subscription_id 2>/dev/null)
  
  cd - > /dev/null
  
  # Validate outputs
  if [ -z "${STORAGE_ACCOUNT}" ] || [ -z "${STORAGE_KEY}" ] || [ -z "${CONTAINER_NAME}" ]; then
    echo -e "${RED}Error: Failed to read Azure Terraform outputs${NC}"
    return 1
  fi
  
  # Set GitHub secrets
  gh secret set AZURE_STORAGE_ACCOUNT --body "${STORAGE_ACCOUNT}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AZURE_STORAGE_ACCOUNT${NC}"
  
  gh secret set AZURE_STORAGE_KEY --body "${STORAGE_KEY}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AZURE_STORAGE_KEY${NC}"
  
  gh secret set AZURE_CONTAINER_NAME --body "${CONTAINER_NAME}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set AZURE_CONTAINER_NAME${NC}"
  
  # Set Azure credentials in JSON format for azure/login action
  if [ -n "${CLIENT_ID}" ] && [ -n "${CLIENT_SECRET}" ] && [ -n "${TENANT_ID}" ] && [ -n "${SUBSCRIPTION_ID}" ]; then
    AZURE_CREDS=$(cat <<EOF
{
  "clientId": "${CLIENT_ID}",
  "clientSecret": "${CLIENT_SECRET}",
  "subscriptionId": "${SUBSCRIPTION_ID}",
  "tenantId": "${TENANT_ID}"
}
EOF
)
    gh secret set AZURE_CREDENTIALS --body "${AZURE_CREDS}" --repo "${REPO_FULL}"
    echo -e "${GREEN}✓ Set AZURE_CREDENTIALS${NC}"
  fi
  
  echo -e "${GREEN}✓ Azure secrets configured successfully${NC}"
  echo ""
  return 0
}

# Function to setup GCP secrets
setup_gcp_secrets() {
  echo -e "${BLUE}Setting up GCP secrets...${NC}"
  
  if [ ! -d "${TERRAFORM_DIR_GCP}" ]; then
    echo -e "${YELLOW}⚠ GCP Terraform directory not found: ${TERRAFORM_DIR_GCP}${NC}"
    return 1
  fi
  
  if [ ! -f "${TERRAFORM_DIR_GCP}/terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠ GCP Terraform state not found${NC}"
    echo "Run 'terraform apply' in ${TERRAFORM_DIR_GCP} first"
    return 1
  fi
  
  cd "${TERRAFORM_DIR_GCP}"
  
  # Extract outputs using terraform output
  BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null)
  PROJECT_ID=$(terraform output -raw gcp_project_id 2>/dev/null)
  SERVICE_ACCOUNT_KEY=$(terraform output -raw service_account_key 2>/dev/null)
  
  cd - > /dev/null
  
  # Validate outputs
  if [ -z "${BUCKET_NAME}" ] || [ -z "${PROJECT_ID}" ] || [ -z "${SERVICE_ACCOUNT_KEY}" ]; then
    echo -e "${RED}Error: Failed to read GCP Terraform outputs${NC}"
    return 1
  fi
  
  # Set GitHub secrets
  gh secret set GCP_BUCKET_NAME --body "${BUCKET_NAME}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set GCP_BUCKET_NAME${NC}"
  
  gh secret set GCP_PROJECT_ID --body "${PROJECT_ID}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set GCP_PROJECT_ID${NC}"
  
  gh secret set GCP_CREDENTIALS --body "${SERVICE_ACCOUNT_KEY}" --repo "${REPO_FULL}"
  echo -e "${GREEN}✓ Set GCP_CREDENTIALS${NC}"
  
  echo -e "${GREEN}✓ GCP secrets configured successfully${NC}"
  echo ""
  return 0
}

# Main execution
AWS_SUCCESS=false
AZURE_SUCCESS=false
GCP_SUCCESS=false

if setup_aws_secrets; then
  AWS_SUCCESS=true
fi

if setup_azure_secrets; then
  AZURE_SUCCESS=true
fi

if setup_gcp_secrets; then
  GCP_SUCCESS=true
fi

# Summary
echo "========================================="
echo -e "${GREEN}GitHub Secrets Configuration Summary${NC}"
echo "========================================="
echo ""

if [ "${AWS_SUCCESS}" = true ]; then
  echo -e "${GREEN}✓ AWS secrets configured${NC}"
  echo "  - AWS_REGION"
  echo "  - AWS_ACCESS_KEY_ID"
  echo "  - AWS_SECRET_ACCESS_KEY"
  echo "  - BACKUP_BUCKET"
else
  echo -e "${YELLOW}⚠ AWS secrets not configured${NC}"
fi
echo ""

if [ "${AZURE_SUCCESS}" = true ]; then
  echo -e "${GREEN}✓ Azure secrets configured${NC}"
  echo "  - AZURE_STORAGE_ACCOUNT"
  echo "  - AZURE_STORAGE_KEY"
  echo "  - AZURE_CONTAINER_NAME"
  echo "  - AZURE_CREDENTIALS"
else
  echo -e "${YELLOW}⚠ Azure secrets not configured${NC}"
fi
echo ""

if [ "${GCP_SUCCESS}" = true ]; then
  echo -e "${GREEN}✓ GCP secrets configured${NC}"
  echo "  - GCP_BUCKET_NAME"
  echo "  - GCP_PROJECT_ID"
  echo "  - GCP_CREDENTIALS"
else
  echo -e "${YELLOW}⚠ GCP secrets not configured${NC}"
fi
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
echo "  2. Test backup workflow: gh workflow run self-heal-agent.yml --repo ${REPO_FULL}"
echo ""

# Exit with success if at least one cloud provider was configured
if [ "${AWS_SUCCESS}" = true ] || [ "${AZURE_SUCCESS}" = true ] || [ "${GCP_SUCCESS}" = true ]; then
  exit 0
else
  echo -e "${RED}Error: No cloud provider secrets were configured${NC}"
  echo "Please deploy at least one cloud infrastructure with Terraform first"
  exit 1
fi
