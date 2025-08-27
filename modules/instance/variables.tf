variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "public_key" {
  description = "Public key for EC2 instances"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

# Wazuh Manager Variables
variable "create_wazuh_manager" {
  description = "Whether to create Wazuh manager instance"
  type        = bool
  default     = true
}

variable "wazuh_instance_type" {
  description = "Instance type for Wazuh manager"
  type        = string
  default     = "t3.medium"
}

variable "wazuh_volume_size" {
  description = "Root volume size for Wazuh manager (GB)"
  type        = number
  default     = 50
}

# Elasticsearch Variables
variable "create_elasticsearch" {
  description = "Whether to create Elasticsearch instance"
  type        = bool
  default     = true
}

variable "elasticsearch_instance_type" {
  description = "Instance type for Elasticsearch"
  type        = string
  default     = "t3.large"
}

variable "elasticsearch_volume_size" {
  description = "Root volume size for Elasticsearch (GB)"
  type        = number
  default     = 100
}

# Kibana Variables
variable "create_kibana" {
  description = "Whether to create Kibana instance"
  type        = bool
  default     = true
}

variable "kibana_instance_type" {
  description = "Instance type for Kibana"
  type        = string
  default     = "t3.medium"
}

variable "kibana_volume_size" {
  description = "Root volume size for Kibana (GB)"
  type        = number
  default     = 30
}

# Logstash Variables
variable "create_logstash" {
  description = "Whether to create Logstash instance"
  type        = bool
  default     = true
}

variable "logstash_instance_type" {
  description = "Instance type for Logstash"
  type        = string
  default     = "t3.medium"
}

variable "logstash_volume_size" {
  description = "Root volume size for Logstash (GB)"
  type        = number
  default     = 30
}
