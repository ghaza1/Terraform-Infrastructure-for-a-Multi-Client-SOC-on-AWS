terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "soc-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "soc-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "soc-infrastructure"
      ManagedBy   = "terraform"
    }
  }
}

# Network Module
module "network" {
  source = "../../modules/network"
  
  environment            = "dev"
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

# Security Module
module "security" {
  source = "../../modules/security"
  
  environment       = "dev"
  vpc_id           = module.network.vpc_id
  vpc_cidr         = module.network.vpc_cidr_block
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

# Instance Module
module "instances" {
  source = "../../modules/instance"
  
  environment             = "dev"
  public_key             = var.public_key
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  iam_instance_profile   = module.security.ec2_instance_profile_name
  
  security_group_ids = [
    module.security.web_security_group_id,
    module.security.ssh_security_group_id,
    module.security.soc_security_group_id
  ]
  
  # Instance configuration
  create_wazuh_manager    = var.create_wazuh_manager
  create_elasticsearch    = var.create_elasticsearch
  create_kibana          = var.create_kibana
  create_logstash        = var.create_logstash
  
  wazuh_instance_type       = var.wazuh_instance_type
  elasticsearch_instance_type = var.elasticsearch_instance_type
  kibana_instance_type      = var.kibana_instance_type
  logstash_instance_type    = var.logstash_instance_type
}
