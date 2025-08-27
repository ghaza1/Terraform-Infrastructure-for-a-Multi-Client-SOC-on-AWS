# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

# Instance Outputs
output "wazuh_manager_private_ip" {
  description = "Private IP of the Wazuh manager"
  value       = module.instances.wazuh_manager_private_ip
}

output "elasticsearch_private_ip" {
  description = "Private IP of the Elasticsearch instance"
  value       = module.instances.elasticsearch_private_ip
}

output "kibana_public_ip" {
  description = "Public IP of the Kibana instance"
  value       = module.instances.kibana_public_ip
}

output "kibana_access_url" {
  description = "URL to access Kibana dashboard"
  value       = module.instances.kibana_public_ip != null ? "http://${module.instances.kibana_public_ip}:5601" : null
}

output "logstash_private_ip" {
  description = "Private IP of the Logstash instance"
  value       = module.instances.logstash_private_ip
}

# Security Outputs
output "key_pair_name" {
  description = "Name of the created key pair"
  value       = module.instances.key_pair_name
}
