# Terraform Infrastructure for a Multi-Client SOC on AWS

This repository contains the Terraform code for deploying a scalable and automated backend infrastructure on AWS. It is designed for a multi-client Security Operations Center (SOC) and demonstrates best practices in IaC, DevOps, and cloud security.

## Project Goal
Create a robust, repeatable, and automated process for provisioning core AWS infrastructure for a cybersecurity platform.

## Architecture
- Modular, secure, and highly available
- Reusable Terraform modules for easy configuration

## Main Components
- **VPC & Subnets**: Logical isolation and security
- **EC2 Instances**: Compute resources for SOC backend
- **Security Groups**: Least privilege enforcement
- **S3 Bucket**: Remote backend for Terraform state
- **IAM Roles & Policies**: Secure, limited permissions
- **Networking**: Route Tables, IGWs, NAT Gateways

## Features
- 100% Infrastructure as Code
- Modular design
- State management (S3 + DynamoDB)
- CI/CD ready
- Security focused

## Repository Structure
```
.
├── modules/
│   ├── network/
│   ├── instance/
│   └── security/
├── environments/
│   ├── dev/
│   └── prod/
├── scripts/
├── README.md
└── .gitignore
```

## Skills Demonstrated
- Infrastructure as Code (Terraform)
- AWS Cloud Computing
- DevOps & Automation
- Scripting (Python)
- Cloud Security
