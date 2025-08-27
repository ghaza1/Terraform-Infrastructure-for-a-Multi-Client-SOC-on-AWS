#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y curl wget unzip

# Install Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | rpm --import -
echo -e '[wazuh]\ngpgcheck=1\ngpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://packages.wazuh.com/4.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh.repo

# Install Wazuh manager
yum install -y wazuh-manager

# Enable and start Wazuh manager
systemctl enable wazuh-manager
systemctl start wazuh-manager

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=1514/tcp
firewall-cmd --permanent --add-port=1515/tcp
firewall-cmd --permanent --add-port=55000/tcp
firewall-cmd --reload

# Set hostname
echo "${environment}-wazuh-manager" > /etc/hostname
hostname ${environment}-wazuh-manager

# Create log file for initialization
echo "Wazuh Manager installation completed at $(date)" >> /var/log/wazuh-init.log
