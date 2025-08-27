output "wazuh_manager_id" {
  description = "ID of the Wazuh manager instance"
  value       = var.create_wazuh_manager ? aws_instance.wazuh_manager[0].id : null
}

output "wazuh_manager_private_ip" {
  description = "Private IP of the Wazuh manager instance"
  value       = var.create_wazuh_manager ? aws_instance.wazuh_manager[0].private_ip : null
}

output "elasticsearch_id" {
  description = "ID of the Elasticsearch instance"
  value       = var.create_elasticsearch ? aws_instance.elasticsearch[0].id : null
}

output "elasticsearch_private_ip" {
  description = "Private IP of the Elasticsearch instance"
  value       = var.create_elasticsearch ? aws_instance.elasticsearch[0].private_ip : null
}

output "kibana_id" {
  description = "ID of the Kibana instance"
  value       = var.create_kibana ? aws_instance.kibana[0].id : null
}

output "kibana_public_ip" {
  description = "Public IP of the Kibana instance"
  value       = var.create_kibana ? aws_instance.kibana[0].public_ip : null
}

output "kibana_private_ip" {
  description = "Private IP of the Kibana instance"
  value       = var.create_kibana ? aws_instance.kibana[0].private_ip : null
}

output "logstash_id" {
  description = "ID of the Logstash instance"
  value       = var.create_logstash ? aws_instance.logstash[0].id : null
}

output "logstash_private_ip" {
  description = "Private IP of the Logstash instance"
  value       = var.create_logstash ? aws_instance.logstash[0].private_ip : null
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.main.key_name
}
