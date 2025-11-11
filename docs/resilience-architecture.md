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

**AWS Location**: `infra/aws/terraform/`
**Azure Location**: `infra/azure/terraform/`
**GCP Location**: `infra/gcp/terraform/`

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

### 2. Backup Scripts

**Location**: `infra/`

Multi-cloud backup scripts using git archive:

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
- Reads Terraform outputs automatically from AWS, Azure, and GCP
- Validates Terraform state exists for each provider
- Sets required secrets via GitHub CLI
- Provides clear next steps and summary

**AWS Secrets Configured**:
- `AWS_REGION`: AWS region for operations
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key
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

**General Requirements**:
- Git and GitHub CLI (gh) authenticated
- Terraform >= 1.0
- Unique resource names for each cloud provider

**AWS Requirements**:
- AWS account with admin access
- AWS CLI configured
- Unique S3 bucket name

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

#### Option B: Deploy Azure Infrastructure

```bash
cd infra/azure/terraform

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

### Step 4: Verify Backup

Check that backups were created successfully:

**AWS**:
```bash
# List backups in S3
aws s3 ls s3://your-bucket-name/

# Check CloudWatch logs
aws logs tail /echoforge/workflows --since 1h
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

**Automated**: Backups run weekly on Sunday at 3 AM UTC automatically.

**Manual**:
```bash
gh workflow run self-heal-agent.yml \
  --field backup_source=aws \
  --field operation=backup
```

### Restoring from Backup

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

3. The workflow will download, verify, and extract the backup.

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

1. Check GitHub Actions logs: `gh run view <run-id> --log-failed`
2. Verify AWS credentials are set correctly
3. Confirm S3 bucket exists and is accessible
4. Check IAM permissions for backup user

#### Restore Fails

1. Verify filename exists in S3 bucket
2. Check archive integrity locally: `tar -tzf backup.tar.gz`
3. Ensure sufficient IAM permissions for S3 GetObject

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

**Checklist**:
- [ ] Review CloudWatch logs for anomalies
- [ ] Verify backup schedule is executing successfully
- [ ] Check S3 bucket lifecycle transitions
- [ ] Audit IAM user permissions (no unnecessary access)
- [ ] Review AWS costs (lifecycle rules working)
- [ ] Confirm GitHub Actions secrets are valid
- [ ] Test Slack notifications
- [ ] Verify KMS key rotation is enabled
- [ ] Check for Terraform drift: `terraform plan`

**Schedule**: First Monday of each month

### Security Considerations

1. **Credentials**: Never commit secrets to version control
2. **IAM**: Use least-privilege principle for all access
3. **Encryption**: All backups encrypted at rest with KMS
4. **Versioning**: Enabled to protect against accidental deletions
5. **Access Logs**: Consider enabling S3 access logging for audit
6. **MFA**: Enable MFA delete on S3 bucket for production
7. **Key Rotation**: KMS key rotation enabled automatically

### Cost Management

**Expected Monthly Costs** (approximate):
- S3 Storage (STANDARD): $0.023/GB
- S3 Storage (STANDARD_IA): $0.0125/GB after 30 days
- S3 Storage (GLACIER): $0.004/GB after 90 days
- KMS Key: $1/month
- KMS Requests: ~$0.03/10,000 requests

**Optimization Tips**:
- Lifecycle rules automatically reduce costs
- Delete old backups manually if over 1 year old
- Monitor S3 storage metrics in AWS Cost Explorer
- Consider using S3 Intelligent-Tiering for unpredictable access

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
- Cross-region replication for AWS
- Backup retention policies
- Automated backup testing
- Performance metrics dashboard
- Cost alerting thresholds
- Multi-region disaster recovery

## Support and Maintenance

### Documentation

- Infrastructure: `infra/aws/terraform/README.md`
- Terraform variables: `infra/aws/terraform/terraform.tfvars.example`
- This document: `docs/resilience-architecture.md`

### Contacts

For issues or questions:
1. Check GitHub Issues
2. Review workflow logs in GitHub Actions
3. Check CloudWatch Logs for operational issues
4. Consult AWS documentation for service-specific issues

### Version History

- v1.0 (Initial): AWS implementation with backup/restore
- Future: Azure and GCP extensions

---

**Last Updated**: November 2024  
**Maintained By**: EchoForge Team
