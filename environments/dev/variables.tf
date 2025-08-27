# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# Security Configuration
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
}

# EC2 Configuration
variable "public_key" {
  description = "Public key for EC2 instances"
  type        = string
}

# Service Configuration
variable "create_wazuh_manager" {
  description = "Whether to create Wazuh manager instance"
  type        = bool
  default     = true
}

variable "create_elasticsearch" {
  description = "Whether to create Elasticsearch instance"
  type        = bool
  default     = true
}

variable "create_kibana" {
  description = "Whether to create Kibana instance"
  type        = bool
  default     = true
}

variable "create_logstash" {
  description = "Whether to create Logstash instance"
  type        = bool
  default     = true
}

# Instance Types
variable "wazuh_instance_type" {
  description = "Instance type for Wazuh manager"
  type        = string
  default     = "t3.medium"
}

variable "elasticsearch_instance_type" {
  description = "Instance type for Elasticsearch"
  type        = string
  default     = "t3.large"
}

variable "kibana_instance_type" {
  description = "Instance type for Kibana"
  type        = string
  default     = "t3.medium"
}

variable "logstash_instance_type" {
  description = "Instance type for Logstash"
  type        = string
  default     = "t3.medium"
}
