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

## Components

### 1. Infrastructure as Code (Terraform)

**Location**: `infra/aws/terraform/`

AWS infrastructure managed by Terraform:
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
- `azure-backup.sh`: Placeholder for Azure Blob Storage
- `gcp-backup.sh`: Placeholder for Google Cloud Storage

Each script creates a timestamped tar.gz archive of the repository HEAD.

### 3. GitHub Actions Workflows

**Location**: `.github/workflows/`

#### Self-Heal Agent (`self-heal-agent.yml`)

**Triggers**:
- Scheduled: Weekly on Sunday at 3 AM UTC
- Manual: Workflow dispatch with parameters

**Capabilities**:
- **Backup**: Creates and uploads repository archive
- **Restore**: Downloads and extracts specified backup
- **Multi-cloud**: Supports AWS, Azure, GCP (extensible)
- **Logging**: Pushes events to CloudWatch Logs

**Parameters** (manual dispatch):
- `backup_source`: Cloud provider (aws/azure/gcp)
- `operation`: backup or restore
- `filename`: Backup file for restore operations

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

Bootstrap script for GitHub Actions secrets:
- Reads Terraform outputs automatically
- Validates Terraform state exists
- Sets required secrets via GitHub CLI
- Provides clear next steps

**Secrets Configured**:
- `AWS_REGION`: AWS region for operations
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key
- `BACKUP_BUCKET`: S3 bucket name
- `SLACK_WEBHOOK_URL`: Optional Slack webhook

## Deployment Guide

### Prerequisites

- AWS account with admin access
- Terraform >= 1.0
- AWS CLI configured
- GitHub CLI (gh) authenticated
- Unique S3 bucket name

### Step 1: Deploy Infrastructure

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

### Step 2: Configure GitHub Secrets

```bash
# Set GITHUB_REPOSITORY_OWNER and GITHUB_REPOSITORY_NAME if not in repo
export GITHUB_REPOSITORY_OWNER="your-org"
export GITHUB_REPOSITORY_NAME="EchoForge"

# Run bootstrap script
./scripts/setup-gh-secrets.sh

# Optional: Add Slack webhook
gh secret set SLACK_WEBHOOK_URL --repo your-org/EchoForge
```

### Step 3: Test Backup Workflow

```bash
# Trigger manual backup
gh workflow run self-heal-agent.yml \
  --field backup_source=aws \
  --field operation=backup

# Monitor workflow
gh run list --workflow=self-heal-agent.yml
gh run watch
```

### Step 4: Verify Backup

```bash
# List backups in S3
aws s3 ls s3://your-bucket-name/

# Check CloudWatch logs
aws logs tail /echoforge/workflows --since 1h
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

Planned infrastructure (not yet implemented):
- Azure Blob Storage with encryption
- Azure Key Vault for secrets
- Service Principal with RBAC
- Terraform module for Azure resources

### GCP Implementation

Planned infrastructure (not yet implemented):
- Google Cloud Storage with encryption
- Cloud KMS for key management
- Service Account with IAM roles
- Terraform module for GCP resources

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
