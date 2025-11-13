# EchoForge Resilience Architecture

This document describes the production resilience stack for EchoForge, a comprehensive disaster recovery and operational monitoring solution.

## Architecture Overview

The resilience infrastructure provides:
- **Multi-cloud backup capabilities** (AWS, Azure, GCP)
- **Automated weekly backups** with manual restore capability
- **SIEM integration** via AWS CloudWatch Logs
- **Real-time notifications** via Slack webhooks
- **Secure, encrypted storage** with lifecycle management
- **Least-privilege access** for all operations
- **Integrity validation** with checksum verification
- **Automated disaster recovery drills** (quarterly)
- **Infrastructure as Code** with Terraform for all cloud providers

## Required Secrets

All secrets are configured via GitHub Actions secrets and can be set using the bootstrap script or manually.

### AWS Secrets (if using AWS)
- `AWS_REGION`: AWS region (e.g., us-west-2)
- `AWS_ACCESS_KEY_ID`: IAM user access key from Terraform
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key from Terraform
- `BACKUP_BUCKET`: S3 bucket name from Terraform

### Azure Secrets (if using Azure)
- `AZURE_STORAGE_ACCOUNT`: Storage account name from Terraform
- `AZURE_STORAGE_KEY`: Storage account access key from Terraform
- `AZURE_CONTAINER_NAME`: Blob container name (default: backups)
- `AZURE_CREDENTIALS`: Service principal credentials in JSON format

### GCP Secrets (if using GCP)
- `GCP_PROJECT_ID`: GCP project identifier
- `GCP_BUCKET_NAME`: Cloud Storage bucket name
- `GCP_CREDENTIALS`: Service account key (base64-encoded JSON)

### Optional Secrets
- `SLACK_WEBHOOK_URL`: Slack webhook for workflow notifications

**Setup**: Run `./scripts/setup-gh-secrets.sh` after deploying Terraform infrastructure.

## Components

### 1. Infrastructure as Code (Terraform)

**Multi-Cloud Terraform Modules**

The backup infrastructure is implemented across three cloud providers with consistent security and lifecycle policies:

#### AWS Infrastructure (`infra/aws/terraform/`)

Each cloud provider has complete Terraform infrastructure:
- **S3 Bucket**: Private, versioned backup storage
- **KMS Key**: Customer-managed encryption with automatic rotation
- **IAM User**: Least-privilege credentials for backup operations
- **Lifecycle Rules**: Automatic cost optimization

**Security Features**:
- SSE-KMS encryption at rest
- All public access blocked
- Versioning enabled for data protection
- IAM permissions limited to S3 Put/Get/List and KMS Encrypt/Decrypt

**Cost Optimization**:
- Transition to STANDARD_IA after 30 days
- Transition to GLACIER after 90 days
- Expire noncurrent versions after 365 days

#### Azure Infrastructure (`infra/azure/terraform/`)

Azure infrastructure managed by Terraform:
- **Resource Group**: Container for Azure resources (optional)
- **Key Vault**: Secure storage for keys and secrets
- **RSA Key**: Customer-managed key (CMK) for encryption
- **Storage Account**: With system-assigned managed identity
- **Blob Container**: Private container for backups
- **Service Principal**: Azure AD app for CI/CD authentication

**Security Features**:
- Customer-managed key (CMK) encryption via Key Vault
- System-assigned managed identity for Storage Account
- Blob versioning and change feed enabled
- Private container with no public access
- Least-privilege service principal with Storage Blob Data Contributor role

**Cost Optimization**:
- Tier to Cool storage after 30 days
- Tier to Archive storage after 90 days
- Delete old versions after 365 days
- Delete snapshots after 365 days

#### GCP Infrastructure (`infra/gcp/terraform/`)

GCP infrastructure managed by Terraform:
- **KMS Key Ring**: Container for encryption keys
- **KMS Crypto Key**: Customer-managed encryption key with 90-day rotation
- **GCS Bucket**: Private, versioned backup storage with CMEK encryption
- **Service Account**: Least-privilege access for backup operations

**Security Features**:
- Customer-managed encryption key (CMEK) via Cloud KMS
- Automatic key rotation every 90 days
- Uniform bucket-level access (no ACLs)
- Versioning enabled for data protection
- Service account with roles/storage.objectAdmin and roles/cloudkms.cryptoKeyEncrypterDecrypter

**Cost Optimization**:
- Transition to NEARLINE storage after 30 days
- Transition to ARCHIVE storage after 90 days
- Delete noncurrent versions after 365 days

### 2. Backup Scripts

**Location**: `infra/`

Multi-cloud backup scripts using git archive:

- `aws-backup.sh`: AWS S3 backup with encryption
- `azure-backup.sh`: Azure Blob Storage backup with authentication
- `gcp-backup.sh`: Google Cloud Storage backup with service account

Each script:
- Creates a timestamped tar.gz archive of the repository HEAD
- Uploads to the respective cloud storage service
- Uses secure authentication (IAM user, service principal, or service account)
- Validates environment variables before execution
- `aws-backup.sh`: Full AWS S3 implementation
- `azure-backup.sh`: Full Azure Blob Storage implementation
- `gcp-backup.sh`: Full Google Cloud Storage implementation
- `checksum-backup.sh`: Backup integrity validation tool
- `aws-cloudwatch-log.sh`: SIEM logging integration

Each script creates a timestamped tar.gz archive of the repository HEAD with checksum validation.

### 3. GitHub Actions Workflows

**Location**: `.github/workflows/`

#### Auto Deploy Resilience (`auto-deploy-resilience.yml`)

**Trigger**: Manual workflow dispatch

**Purpose**: Deploy and manage infrastructure across all cloud providers

**Parameters**:
- `cloud_provider`: aws/azure/gcp/all
- `terraform_action`: plan/apply/destroy
- `auto_approve`: Boolean for unattended operations

**Features**:
- Multi-cloud infrastructure provisioning
- Terraform validation and planning
- Safe destroy operations
- Post-deployment secret configuration guidance

#### Self-Heal Agent (`self-heal-agent.yml`)

**Triggers**:
- Scheduled: Weekly on Sunday at 3 AM UTC
- Manual: Workflow dispatch with parameters

**Capabilities**:
- **Backup**: Creates and uploads repository archive to AWS, Azure, or GCP
- **Restore**: Downloads and extracts specified backup from any cloud provider
- **Multi-cloud**: Full support for AWS, Azure, and GCP with native authentication
- **Logging**: Pushes events to CloudWatch Logs (AWS only)
- **Backup**: Creates and uploads repository archive to any cloud provider
- **Restore**: Downloads and extracts specified backup from any cloud provider
- **Multi-cloud**: Fully supports AWS, Azure, GCP
- **Logging**: Pushes events to CloudWatch Logs
- **Integrity**: Generates and validates checksums

**Parameters** (manual dispatch):
- `backup_source`: Cloud provider (aws/azure/gcp)
- `operation`: backup or restore
- `filename`: Backup file for restore operations

#### Disaster Recovery Drill (`dr-drill.yml`)

**Triggers**:
- Scheduled: First Monday of Jan, Apr, Jul, Oct at 9 AM UTC
- Manual: Workflow dispatch with parameters

**Purpose**: Quarterly validation of backup and restore procedures

**Parameters** (manual dispatch):
- `cloud_provider`: Cloud provider to test (aws/azure/gcp)
- `backup_age_days`: Age of backup to restore (default: 30)
- `skip_validation`: Skip detailed validation for faster testing

**Features**:
- Automated backup selection based on age
- Complete restore and validation workflow
- Integrity checking with checksums
- Critical file validation
- Comprehensive drill reporting
- CloudWatch logging integration

#### Slack Notification (`notify-slack.yml`)

**Trigger**: After Self-Heal Agent workflow completes

**Features**:
- Rich status messages with color coding
- Workflow details (status, run number, duration)
- Direct link to workflow run
- Gracefully skips if webhook not configured

### 4. SIEM Integration

**Location**: `infra/aws-cloudwatch-log.sh`

CloudWatch Logs integration for centralized logging:
- Creates log group and stream automatically
- Accepts log messages via stdin or parameter
- Enables log aggregation for security monitoring
- Queryable via CloudWatch Insights

**Use Cases**:
- Audit trail of backup/restore operations
- Security event monitoring
- Compliance reporting
- Anomaly detection

### 5. Secret Management

**Location**: `scripts/setup-gh-secrets.sh`

Bootstrap script for GitHub Actions secrets across all cloud providers:
- Reads Terraform outputs automatically from AWS, Azure, and GCP directories
- Validates Terraform state exists for each cloud
- Sets required secrets via GitHub CLI
- Provides clear next steps and configuration summary
- Handles missing providers gracefully
- Reads Terraform outputs automatically from AWS, Azure, and GCP
- Validates Terraform state exists for each provider
- Sets required secrets via GitHub CLI
- Provides clear next steps and summary

**AWS Secrets Configured**:
- `AWS_REGION`: AWS region for operations
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key
- `AWS_BACKUP_BUCKET`: S3 bucket name
- `BACKUP_BUCKET`: Legacy name for backward compatibility

**Azure Secrets Configured**:
- `AZURE_CREDENTIALS`: JSON credentials for azure/login action (clientId, clientSecret, subscriptionId, tenantId)
- `AZURE_STORAGE_ACCOUNT`: Storage account name
- `AZURE_STORAGE_CONTAINER`: Blob container name

**GCP Secrets Configured**:
- `GCP_SA_KEY`: Service account key JSON for authentication
- `GCP_PROJECT_ID`: GCP project ID
- `GCS_BUCKET`: GCS bucket name

**Optional**:
- `BACKUP_BUCKET`: S3 bucket name

**Azure Secrets Configured**:
- `AZURE_STORAGE_ACCOUNT`: Storage account name
- `AZURE_STORAGE_KEY`: Storage account access key
- `AZURE_CONTAINER_NAME`: Blob container name
- `AZURE_CREDENTIALS`: Service principal credentials (JSON)

**GCP Secrets Configured**:
- `GCP_PROJECT_ID`: GCP project identifier
- `GCP_BUCKET_NAME`: Cloud Storage bucket name
- `GCP_CREDENTIALS`: Service account key (base64-encoded JSON)

**Optional Secrets**:
- `SLACK_WEBHOOK_URL`: Slack webhook for notifications

## Deployment Guide

### Prerequisites

**General**:
- GitHub CLI (gh) authenticated
- Git configured with repository access
- Terraform >= 1.0

**AWS**:
**General Requirements**:
- Git and GitHub CLI (gh) authenticated
- Terraform >= 1.0
- Unique resource names for each cloud provider

**AWS Requirements**:
- AWS account with admin access
- AWS CLI configured
- Unique S3 bucket name

**Azure** (Optional):
- Azure subscription with admin access
- Azure CLI installed and authenticated (`az login`)
- Unique Key Vault name (3-24 chars)
- Unique Storage Account name (3-24 chars, lowercase alphanumeric)

**GCP** (Optional):
- GCP project with admin access
- gcloud CLI installed and authenticated (`gcloud auth login`)
- Unique GCS bucket name
- Required APIs enabled (Storage, KMS, IAM)

### Step 1: Deploy AWS Infrastructure
**Azure Requirements**:
- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Unique storage account name (3-24 lowercase alphanumeric)

**GCP Requirements**:
- GCP project with billing enabled
- Google Cloud SDK installed and authenticated (`gcloud auth login`)
- Unique bucket name (lowercase, hyphens allowed)

### Step 1: Deploy Infrastructure

Choose which cloud provider(s) to deploy:

#### Option A: Deploy AWS Infrastructure

```bash
cd infra/aws/terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set bucket_name

# Initialize and apply
terraform init
terraform plan
terraform apply
```

### Step 2: Deploy Azure Infrastructure (Optional)
#### Option B: Deploy Azure Infrastructure

```bash
cd infra/azure/terraform

# Create terraform.tfvars with required values
cat > terraform.tfvars <<TFVARS
resource_group_name   = "echoforge-backup-rg"
key_vault_name        = "echoforge-kv-unique"
storage_account_name  = "echoforgestunique"
container_name        = "backups"
location              = "East US"
TFVARS

# Initialize and apply
terraform init
terraform plan
terraform apply
```

**Note**: Key Vault and Storage Account names must be globally unique across all Azure customers.

### Step 3: Deploy GCP Infrastructure (Optional)

```bash
cd infra/gcp/terraform

# Create terraform.tfvars with required values
cat > terraform.tfvars <<TFVARS
project_id           = "your-gcp-project-id"
bucket_name          = "echoforge-backup-unique-bucket"
region               = "us-central1"
TFVARS
# Ensure Azure CLI is authenticated
az login

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set storage_account_name

# Initialize and apply
terraform init
terraform plan
terraform apply
```

**Note**: Ensure the following APIs are enabled in your GCP project:
- Cloud Storage API
- Cloud KMS API
- Identity and Access Management (IAM) API

### Step 4: Configure GitHub Secrets

```bash
# Run from repository root
# The script will automatically detect and configure all deployed cloud providers

#### Option C: Deploy GCP Infrastructure

```bash
cd infra/gcp/terraform

# Ensure gcloud is authenticated
gcloud auth login
gcloud auth application-default login

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set:
#   - gcp_project_id
#   - bucket_name

# Initialize and apply
terraform init
terraform plan
terraform apply
```

#### Option D: Deploy All Cloud Providers

Use the automated workflow:

```bash
# Deploy AWS
gh workflow run auto-deploy-resilience.yml \
  --field cloud_provider=aws \
  --field terraform_action=plan

# After reviewing plan, apply
gh workflow run auto-deploy-resilience.yml \
  --field cloud_provider=aws \
  --field terraform_action=apply \
  --field auto_approve=true

# Repeat for Azure and GCP
# ...or deploy all at once:
gh workflow run auto-deploy-resilience.yml \
  --field cloud_provider=all \
  --field terraform_action=apply \
  --field auto_approve=true
```

### Step 2: Configure GitHub Secrets

The bootstrap script automatically configures secrets for all deployed cloud providers:

```bash
# Run bootstrap script (configures all deployed providers)
./scripts/setup-gh-secrets.sh

# Verify secrets were set
gh secret list

# Optional: Add Slack webhook for notifications
gh secret set SLACK_WEBHOOK_URL
```

The script will:
- Detect which cloud providers have been deployed (AWS/Azure/GCP)
- Read Terraform outputs from each provider
- Set appropriate GitHub Actions secrets
- Provide a summary and next steps

### Step 5: Test Backup Workflows

**Test AWS Backup**:
```bash
The script will detect which Terraform states exist and configure secrets accordingly.

### Step 3: Test Backup Workflow

Test backup operations for each cloud provider:

```bash
# Test AWS backup
gh workflow run self-heal-agent.yml \
  --field backup_source=aws \
  --field operation=backup

# Test Azure backup
gh workflow run self-heal-agent.yml \
  --field backup_source=azure \
  --field operation=backup

# Test GCP backup
gh workflow run self-heal-agent.yml \
  --field backup_source=gcp \
  --field operation=backup

# Monitor workflow
gh run list --workflow=self-heal-agent.yml
gh run watch
```

**Test Azure Backup** (if deployed):
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=azure \
  --field operation=backup

gh run watch
```

**Test GCP Backup** (if deployed):
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=gcp \
  --field operation=backup

gh run watch
```

### Step 6: Verify Backups

Check that backups were created successfully:

**AWS**:
```bash
aws s3 ls s3://your-bucket-name/
```

**Azure**:
```bash
az storage blob list \
  --account-name your-storage-account \
  --container-name backups \
  --output table
```

**GCP**:
```bash
gsutil ls gs://your-bucket-name/
```

**Azure**:
```bash
# List backups in Azure Blob Storage
az storage blob list \
  --account-name your-storage-account \
  --container-name backups \
  --output table
```

**GCP**:
```bash
# List backups in Cloud Storage
gsutil ls gs://your-bucket-name/
# or
gcloud storage ls gs://your-bucket-name/
```

## Operational Procedures

### Performing a Backup

**Automated**: Backups run weekly on Sunday at 3 AM UTC automatically (AWS only).

**Manual AWS Backup**:
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=aws \
  --field operation=backup
```

**Manual Azure Backup**:
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=azure \
  --field operation=backup
```

**Manual GCP Backup**:
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=gcp \
  --field operation=backup
```

### Restoring from Backup

#### AWS Restore

1. List available backups:
   ```bash
   aws s3 ls s3://your-bucket-name/
   ```

2. Trigger restore workflow:
   ```bash
   gh workflow run self-heal-agent.yml \
     --field backup_source=aws \
     --field operation=restore \
     --field filename=echoforge-backup-20231115_030000.tar.gz
   ```

#### Azure Restore

1. List available backups:
   ```bash
   az storage blob list \
     --account-name your-storage-account \
     --container-name backups \
     --output table
   ```

2. Trigger restore workflow:
   ```bash
   gh workflow run self-heal-agent.yml \
     --field backup_source=azure \
     --field operation=restore \
     --field filename=echoforge-backup-20231115_030000.tar.gz
   ```

#### GCP Restore

1. List available backups:
   ```bash
   gsutil ls gs://your-bucket-name/
   ```

2. Trigger restore workflow:
   ```bash
   gh workflow run self-heal-agent.yml \
     --field backup_source=gcp \
     --field operation=restore \
     --field filename=echoforge-backup-20231115_030000.tar.gz
   ```

**Note**: The workflow will download, verify, and extract the backup to `/tmp/restore/` in the GitHub Actions runner.

### Monitoring Operations

**CloudWatch Logs**:
```bash
# View recent logs
aws logs tail /echoforge/workflows --follow

# Query logs
aws logs filter-log-events \
  --log-group-name /echoforge/workflows \
  --start-time $(date -d '7 days ago' +%s)000
```

**GitHub Actions**:
```bash
# List recent workflow runs
gh run list --workflow=self-heal-agent.yml --limit 10

# View specific run
gh run view <run-id>
```

**Slack Notifications**: Check your Slack channel for automated status updates.

### Troubleshooting

#### Backup Fails

**AWS**:
1. Check GitHub Actions logs: `gh run view <run-id> --log-failed`
2. Verify AWS credentials are set correctly
3. Confirm S3 bucket exists and is accessible
4. Check IAM permissions for backup user

**Azure**:
1. Check GitHub Actions logs: `gh run view <run-id> --log-failed`
2. Verify Azure credentials (service principal) are correct
3. Confirm Storage Account and container exist
4. Check RBAC permissions for service principal

**GCP**:
1. Check GitHub Actions logs: `gh run view <run-id> --log-failed`
2. Verify GCP service account key is valid
3. Confirm GCS bucket exists and is accessible
4. Check IAM roles for service account

#### Restore Fails

**AWS**:
1. Verify filename exists in S3 bucket
2. Check archive integrity locally: `tar -tzf backup.tar.gz`
3. Ensure sufficient IAM permissions for S3 GetObject

**Azure**:
1. Verify filename exists in Azure Blob Storage
2. Check archive integrity after download
3. Ensure service principal has Storage Blob Data Reader role

**GCP**:
1. Verify filename exists in GCS bucket
2. Check archive integrity after download
3. Ensure service account has storage.objectViewer role

#### No Slack Notifications

1. Verify SLACK_WEBHOOK_URL secret is set: `gh secret list`
2. Test webhook manually with curl
3. Check workflow run logs for errors

## Best Practices

### Quarterly Restore Drills

**Purpose**: Validate backup integrity and restore procedures

**Procedure**:
1. Select a backup from the previous quarter
2. Perform a test restore to a temporary location
3. Verify all critical files are present
4. Document any issues or improvements
5. Update runbooks if needed

**Schedule**: First week of each quarter (Jan, Apr, Jul, Oct)

### Monthly Admin Audits

**Purpose**: Ensure infrastructure health and security compliance

**Multi-Cloud Checklist**:

**AWS**:
- [ ] Review CloudWatch logs for anomalies
- [ ] Verify backup schedule is executing successfully
- [ ] Check S3 bucket lifecycle transitions
- [ ] Audit IAM user permissions (no unnecessary access)
- [ ] Review AWS costs (lifecycle rules working)
- [ ] Verify KMS key rotation is enabled
- [ ] Check for Terraform drift: `cd infra/aws/terraform && terraform plan`

**Azure** (if deployed):
- [ ] Check Azure Storage Account metrics
- [ ] Verify lifecycle management policies are working
- [ ] Audit service principal permissions
- [ ] Review Azure costs (storage tiers)
- [ ] Verify Key Vault access policies
- [ ] Check for Terraform drift: `cd infra/azure/terraform && terraform plan`

**GCP** (if deployed):
- [ ] Check GCS bucket metrics
- [ ] Verify lifecycle policies are working
- [ ] Audit service account IAM roles
- [ ] Review GCP costs (storage classes)
- [ ] Verify KMS key rotation
- [ ] Check for Terraform drift: `cd infra/gcp/terraform && terraform plan`

**General**:
- [ ] Confirm GitHub Actions secrets are valid
- [ ] Test Slack notifications
- [ ] Verify all backup workflows are functional

**Schedule**: First Monday of each month

### Security Considerations

1. **Credentials**: Never commit secrets to version control
2. **Least Privilege**: Use least-privilege principle for all access (IAM users, service principals, service accounts)
3. **Encryption**: All backups encrypted at rest with customer-managed keys (CMK/CMEK)
4. **Versioning**: Enabled on all storage to protect against accidental deletions
5. **Access Logs**: Consider enabling access logging for audit trails (S3, Azure Storage, GCS)
6. **MFA**: Enable MFA delete on production buckets where supported
7. **Key Rotation**: 
   - AWS: KMS key rotation enabled automatically
   - Azure: Manual key rotation recommended annually
   - GCP: Automatic rotation every 90 days
8. **Private Storage**: All buckets/containers are private with no public access
9. **Identity**: Use managed identities and service accounts instead of long-lived credentials where possible

### Cost Management

**Expected Monthly Costs** (approximate per cloud provider):

**AWS**:
- S3 Storage (STANDARD): $0.023/GB
- S3 Storage (STANDARD_IA): $0.0125/GB after 30 days
- S3 Storage (GLACIER): $0.004/GB after 90 days
- KMS Key: $1/month
- KMS Requests: ~$0.03/10,000 requests

**Azure**:
- Storage (Hot): $0.018/GB
- Storage (Cool): $0.01/GB after 30 days
- Storage (Archive): $0.002/GB after 90 days
- Key Vault Key: $1/month for RSA 2048-bit key
- Storage transactions: minimal cost for infrequent access

**GCP**:
- Storage (Standard): $0.020/GB
- Storage (Nearline): $0.010/GB after 30 days
- Storage (Archive): $0.0012/GB after 90 days
- KMS Key: $0.06/month per active key
- KMS Operations: $0.03/10,000 operations

**Optimization Tips**:
- Lifecycle rules automatically reduce costs across all providers
- Delete old backups manually if over 1 year old
- Monitor storage metrics in each cloud provider's cost management tool
- Consider using intelligent tiering where available
- Use a single provider for primary backups and others for DR if cost is a concern

## Future Enhancements

### Azure Implementation

Azure infrastructure managed by Terraform:
- **Storage Account**: Geo-redundant storage with versioning
- **Blob Container**: Private container for backups
- **Key Vault**: Secure storage for encryption keys
- **Service Principal**: Application identity with RBAC
- **Lifecycle Policy**: Automated cost optimization

**Security Features**:
- Customer-managed encryption keys
- Geo-redundant storage (GRS)
- Versioning enabled for data protection
- Service Principal with Storage Blob Data Contributor role
- HTTPS-only access

**Cost Optimization**:
- Transition to Cool tier after 30 days
- Archive after 90 days
- Delete old versions after 365 days

### GCP Implementation

GCP infrastructure managed by Terraform:
- **Cloud Storage Bucket**: Versioned storage with KMS encryption
- **KMS Key Ring**: Container for encryption keys
- **KMS Crypto Key**: Customer-managed encryption with rotation
- **Service Account**: Application identity with IAM roles
- **Lifecycle Policies**: Multi-tier storage optimization

**Security Features**:
- Customer-managed encryption with Cloud KMS
- Automatic key rotation (90 days)
- Versioning enabled
- Service Account with least-privilege permissions
- Uniform bucket-level access (no ACLs)
- Public access prevention enforced

**Cost Optimization**:
- Transition to NEARLINE after 30 days
- Transition to COLDLINE after 90 days
- Transition to ARCHIVE after 180 days
- Delete old versions (keeps 5 most recent)

### Additional Features

Consider adding:
- **Cross-region replication** for all cloud providers for geographical redundancy
- **Backup retention policies** with automatic cleanup based on age and importance
- **Automated backup testing** to validate backup integrity on a schedule
- **Performance metrics dashboard** to track backup/restore times and success rates
- **Cost alerting thresholds** to monitor and control multi-cloud storage expenses
- **Multi-region disaster recovery** with automated failover capabilities
- **Backup encryption verification** to ensure data integrity
- **Compliance reporting** for audit and regulatory requirements
- **Backup deduplication** to reduce storage costs across multiple backups

## Support and Maintenance

### Documentation

**Infrastructure Documentation**:
- AWS: `infra/aws/terraform/` - S3, KMS, IAM configuration
- Azure: `infra/azure/terraform/` - Storage Account, Key Vault, Service Principal
- GCP: `infra/gcp/terraform/` - GCS, Cloud KMS, Service Account
- This document: `docs/resilience-architecture.md`

**Backup Scripts**:
- `infra/aws-backup.sh` - AWS backup implementation
- `infra/azure-backup.sh` - Azure backup implementation
- `infra/gcp-backup.sh` - GCP backup implementation

**Configuration**:
- `scripts/setup-gh-secrets.sh` - Multi-cloud secrets setup
- `.github/workflows/self-heal-agent.yml` - Backup/restore workflow

### Contacts

For issues or questions:
1. Check GitHub Issues
2. Review workflow logs in GitHub Actions
3. Check CloudWatch Logs for operational issues
4. Consult AWS documentation for service-specific issues

### Version History

- **v2.0 (Current)**: Multi-cloud implementation with AWS, Azure, and GCP
  - Added Azure Terraform module with Key Vault and Storage Account
  - Added GCP Terraform module with Cloud KMS and GCS
  - Updated backup scripts for Azure and GCP
  - Enhanced setup script for multi-cloud configuration
  - Updated workflow with native cloud authentication
- **v1.0**: Initial AWS implementation with backup/restore

---

**Last Updated**: November 2024  
**Maintained By**: EchoForge Team
