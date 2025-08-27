# AWS Configuration
aws_region = "us-east-1"

# Network Configuration
vpc_cidr              = "10.1.0.0/16"
public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.10.0/24", "10.1.20.0/24"]

# Security Configuration (more restrictive for production)
allowed_ssh_cidrs = ["203.0.113.0/24"]  # Replace with your actual office IP range

# EC2 Configuration
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-production-public-key-here"

# Service Configuration
create_wazuh_manager = true
create_elasticsearch = true
create_kibana       = true
create_logstash     = true

# Instance Types (larger for production environment)
wazuh_instance_type       = "t3.large"
elasticsearch_instance_type = "r5.xlarge"
kibana_instance_type      = "t3.medium"
logstash_instance_type    = "t3.large"

# Volume Sizes (larger for production)
wazuh_volume_size       = 100
elasticsearch_volume_size = 500
kibana_volume_size      = 50
logstash_volume_size    = 100
