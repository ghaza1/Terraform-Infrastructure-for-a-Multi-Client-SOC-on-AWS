#!/bin/bash

# Update system
yum update -y

# Install Java 11
yum install -y java-11-amazon-corretto

# Add Elasticsearch repository
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo '[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md' > /etc/yum.repos.d/elasticsearch.repo

# Install Logstash
yum install -y --enablerepo=elasticsearch logstash

# Configure Logstash
cat > /etc/logstash/conf.d/wazuh.conf << EOF
input {
  beats {
    port => 5044
  }
}

filter {
  if [agent][type] == "wazuh" {
    if [data][srcip] {
      mutate {
        add_field => { "src_ip" => "%{[data][srcip]}" }
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["${elasticsearch_ip}:9200"]
    index => "wazuh-alerts-%{+YYYY.MM.dd}"
  }
}
EOF

# Enable and start Logstash
systemctl enable logstash
systemctl start logstash

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=5044/tcp
firewall-cmd --reload

# Set hostname
echo "${environment}-logstash" > /etc/hostname
hostname ${environment}-logstash

# Create log file for initialization
echo "Logstash installation completed at $(date)" >> /var/log/logstash-init.log
