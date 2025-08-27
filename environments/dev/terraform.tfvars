# AWS Configuration
aws_region = "us-east-1"

# Network Configuration
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24"]

# Security Configuration
allowed_ssh_cidrs = ["10.0.0.0/16"]  # Restrict to VPC only for dev

# EC2 Configuration
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-public-key-here"

# Service Configuration
create_wazuh_manager = true
create_elasticsearch = true
create_kibana       = true
create_logstash     = true

# Instance Types (smaller for dev environment)
wazuh_instance_type       = "t3.small"
elasticsearch_instance_type = "t3.medium"
kibana_instance_type      = "t3.small"
logstash_instance_type    = "t3.small"
