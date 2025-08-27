# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${var.environment}-keypair"
  public_key = var.public_key

  tags = {
    Name        = "${var.environment}-keypair"
    Environment = var.environment
  }
}

# Wazuh Manager Instance
resource "aws_instance" "wazuh_manager" {
  count                  = var.create_wazuh_manager ? 1 : 0
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.wazuh_instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = var.wazuh_volume_size
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data/wazuh_manager.sh", {
    environment = var.environment
  }))

  tags = {
    Name        = "${var.environment}-wazuh-manager"
    Environment = var.environment
    Service     = "wazuh"
    Role        = "manager"
  }
}

# Elasticsearch Instance
resource "aws_instance" "elasticsearch" {
  count                  = var.create_elasticsearch ? 1 : 0
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.elasticsearch_instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = var.elasticsearch_volume_size
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data/elasticsearch.sh", {
    environment = var.environment
  }))

  tags = {
    Name        = "${var.environment}-elasticsearch"
    Environment = var.environment
    Service     = "elasticsearch"
    Role        = "search"
  }
}

# Kibana Instance
resource "aws_instance" "kibana" {
  count                  = var.create_kibana ? 1 : 0
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.kibana_instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = var.kibana_volume_size
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data/kibana.sh", {
    environment           = var.environment
    elasticsearch_ip      = var.create_elasticsearch ? aws_instance.elasticsearch[0].private_ip : ""
  }))

  tags = {
    Name        = "${var.environment}-kibana"
    Environment = var.environment
    Service     = "kibana"
    Role        = "visualization"
  }
}

# Logstash Instance
resource "aws_instance" "logstash" {
  count                  = var.create_logstash ? 1 : 0
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.logstash_instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = var.logstash_volume_size
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data/logstash.sh", {
    environment           = var.environment
    elasticsearch_ip      = var.create_elasticsearch ? aws_instance.elasticsearch[0].private_ip : ""
  }))

  tags = {
    Name        = "${var.environment}-logstash"
    Environment = var.environment
    Service     = "logstash"
    Role        = "data-processing"
  }
}
