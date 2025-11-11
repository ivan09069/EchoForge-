# EchoForge Infrastructure

This directory contains all infrastructure and operational tooling for EchoForge's production resilience stack.

## Directory Structure

```
infra/
├── aws/
│   └── terraform/          # AWS infrastructure as code
│       ├── main.tf         # Main Terraform configuration
│       ├── variables.tf    # Input variables
│       ├── outputs.tf      # Output values
│       └── README.md       # Terraform-specific documentation
├── aws-backup.sh           # AWS backup script
├── azure-backup.sh         # Azure backup script (placeholder)
├── gcp-backup.sh           # GCP backup script (placeholder)
└── aws-cloudwatch-log.sh   # CloudWatch logging integration
```

## Quick Start

### 1. Deploy AWS Infrastructure

```bash
cd aws/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your unique bucket name
terraform init
terraform apply
```

### 2. Configure GitHub Secrets

```bash
cd ../../..  # Back to repo root
./scripts/setup-gh-secrets.sh
```

### 3. Test Backup

```bash
# Trigger manual backup workflow
gh workflow run self-heal-agent.yml \
  --field backup_source=aws \
  --field operation=backup
```

## Backup Scripts

### aws-backup.sh

Production-ready AWS S3 backup script.

**Requirements**:
- AWS CLI installed
- Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `BACKUP_BUCKET`

**Usage**:
```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_REGION="us-west-2"
export BACKUP_BUCKET="your-bucket-name"
./aws-backup.sh
```

### azure-backup.sh & gcp-backup.sh

Placeholder scripts for future Azure and GCP implementations. Currently create archives but don't upload.

## CloudWatch Integration

### aws-cloudwatch-log.sh

Sends log events to AWS CloudWatch Logs for SIEM integration.

**Usage**:
```bash
# Send a log message
echo "Backup completed successfully" | ./aws-cloudwatch-log.sh

# Or use default message
./aws-cloudwatch-log.sh
```

**Environment variables**:
- `LOG_GROUP_NAME`: CloudWatch log group (default: `/echoforge/workflows`)
- `LOG_STREAM_NAME`: CloudWatch log stream (default: `backup-YYYYMMDD`)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

## Multi-Cloud Strategy

The infrastructure is designed to be cloud-agnostic with provider-specific implementations:

- **AWS**: Full implementation (Terraform + backup script)
- **Azure**: Planned (Terraform + backup script stubs ready)
- **GCP**: Planned (Terraform + backup script stubs ready)

To add Azure or GCP support:

1. Create Terraform configuration in `azure/terraform/` or `gcp/terraform/`
2. Implement upload logic in `azure-backup.sh` or `gcp-backup.sh`
3. Update GitHub Actions workflows to configure respective credentials
4. Update `scripts/setup-gh-secrets.sh` to handle new secrets

## Security Best Practices

1. **Never commit secrets**: Use GitHub Actions secrets or environment variables
2. **Least privilege**: IAM policies grant only necessary permissions
3. **Encryption**: All backups encrypted at rest with KMS
4. **Versioning**: S3 versioning enabled for data protection
5. **Access control**: All S3 public access blocked

## Troubleshooting

### Backup fails with authentication error

Check that AWS credentials are properly set in GitHub secrets:
```bash
gh secret list --repo your-org/EchoForge
```

### CloudWatch logs not appearing

Verify the IAM user has CloudWatch Logs permissions:
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

### Script permission denied

Make scripts executable:
```bash
chmod +x *.sh
```

## Documentation

- [Resilience Architecture](../docs/resilience-architecture.md) - Complete architecture guide
- [Terraform README](aws/terraform/README.md) - AWS infrastructure details

## Support

For issues or questions, open a GitHub issue or refer to the main documentation.
