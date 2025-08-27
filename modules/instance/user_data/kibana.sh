#!/bin/bash

# Update system
yum update -y

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

# Install Kibana
yum install -y --enablerepo=elasticsearch kibana

# Configure Kibana
cat > /etc/kibana/kibana.yml << EOF
server.port: 5601
server.host: "0.0.0.0"
server.name: "${environment}-kibana"
elasticsearch.hosts: ["http://${elasticsearch_ip}:9200"]
EOF

# Enable and start Kibana
systemctl enable kibana
systemctl start kibana

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=5601/tcp
firewall-cmd --reload

# Set hostname
echo "${environment}-kibana" > /etc/hostname
hostname ${environment}-kibana

# Create log file for initialization
echo "Kibana installation completed at $(date)" >> /var/log/kibana-init.log
