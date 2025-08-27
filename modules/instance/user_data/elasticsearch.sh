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

# Install Elasticsearch
yum install -y --enablerepo=elasticsearch elasticsearch

# Configure Elasticsearch
cat > /etc/elasticsearch/elasticsearch.yml << EOF
cluster.name: ${environment}-soc-cluster
node.name: ${environment}-elasticsearch-node
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
EOF

# Set JVM heap size
echo '-Xms2g' >> /etc/elasticsearch/jvm.options
echo '-Xmx2g' >> /etc/elasticsearch/jvm.options

# Enable and start Elasticsearch
systemctl enable elasticsearch
systemctl start elasticsearch

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=9200/tcp
firewall-cmd --permanent --add-port=9300/tcp
firewall-cmd --reload

# Set hostname
echo "${environment}-elasticsearch" > /etc/hostname
hostname ${environment}-elasticsearch

# Create log file for initialization
echo "Elasticsearch installation completed at $(date)" >> /var/log/elasticsearch-init.log
