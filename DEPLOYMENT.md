# SOC Infrastructure Deployment Guide

## Prerequisites

1. **Install Required Tools:**
   ```bash
   # Install Terraform
   # Windows (using Chocolatey)
   choco install terraform
   
   # Install AWS CLI
   # Windows (using MSI installer)
   # Download from: https://aws.amazon.com/cli/
   
   # Install Python dependencies
   pip install -r requirements.txt
   ```

2. **Configure AWS Credentials:**
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and default region
   ```

## Quick Start

1. **Set up backend resources:**
   ```bash
   python scripts/setup_backend.py
   ```

2. **Update configuration:**
   - Edit `environments/dev/terraform.tfvars`
   - Replace the public key with your actual SSH public key
   - Adjust CIDR blocks if needed

3. **Deploy development environment:**
   ```bash
   # Using Python script
   python scripts/deploy.py --environment dev --action plan
   python scripts/deploy.py --environment dev --action apply
   
   # Using Makefile
   make dev-plan
   make dev-apply
   ```

4. **Access your infrastructure:**
   ```bash
   # Get outputs including Kibana URL
   python scripts/deploy.py --environment dev --action output
   ```

## Environment Management

### Development Environment
```bash
# Plan changes
make plan ENV=dev

# Apply changes
make apply ENV=dev

# Destroy infrastructure
make destroy ENV=dev
```

### Production Environment
```bash
# Plan changes
make plan ENV=prod

# Apply changes (with confirmation)
make apply ENV=prod

# Auto-apply (skip confirmation)
make apply-auto ENV=prod
```

## Security Notes

- Update SSH CIDR blocks in `terraform.tfvars`
- Use strong SSH keys
- Review security groups before deployment
- Enable AWS CloudTrail for audit logging

## Troubleshooting

1. **Terraform state conflicts:**
   ```bash
   # Force unlock (use carefully)
   terraform force-unlock LOCK_ID
   ```

2. **Clean temporary files:**
   ```bash
   make clean
   ```

3. **Validate configuration:**
   ```bash
   make validate ENV=dev
   ```

## Architecture Components

- **VPC**: Isolated network environment
- **Subnets**: Public and private subnets across AZs
- **Security Groups**: Fine-grained access controls
- **EC2 Instances**: Wazuh, Elasticsearch, Kibana, Logstash
- **IAM**: Least privilege roles and policies
