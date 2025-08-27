#!/usr/bin/env python3
"""
SOC Infrastructure Setup Script

This script helps set up the initial AWS resources required for the Terraform backend,
including S3 buckets for state storage and DynamoDB table for state locking.
"""

import boto3
import json
import sys
from botocore.exceptions import ClientError, NoCredentialsError


class AWSSetup:
    def __init__(self, region='us-east-1'):
        self.region = region
        try:
            self.s3_client = boto3.client('s3', region_name=region)
            self.dynamodb_client = boto3.client('dynamodb', region_name=region)
            print(f"✅ AWS clients initialized for region: {region}")
        except NoCredentialsError:
            print("❌ AWS credentials not found. Please configure AWS CLI.")
            sys.exit(1)
    
    def create_s3_bucket(self, bucket_name):
        """Create S3 bucket for Terraform state"""
        try:
            if self.region == 'us-east-1':
                self.s3_client.create_bucket(Bucket=bucket_name)
            else:
                self.s3_client.create_bucket(
                    Bucket=bucket_name,
                    CreateBucketConfiguration={'LocationConstraint': self.region}
                )
            
            # Enable versioning
            self.s3_client.put_bucket_versioning(
                Bucket=bucket_name,
                VersioningConfiguration={'Status': 'Enabled'}
            )
            
            # Enable encryption
            self.s3_client.put_bucket_encryption(
                Bucket=bucket_name,
                ServerSideEncryptionConfiguration={
                    'Rules': [{
                        'ApplyServerSideEncryptionByDefault': {
                            'SSEAlgorithm': 'AES256'
                        }
                    }]
                }
            )
            
            # Block public access
            self.s3_client.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': True,
                    'IgnorePublicAcls': True,
                    'BlockPublicPolicy': True,
                    'RestrictPublicBuckets': True
                }
            )
            
            print(f"✅ S3 bucket '{bucket_name}' created successfully")
            return True
            
        except ClientError as e:
            if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
                print(f"⚠️  S3 bucket '{bucket_name}' already exists")
                return True
            else:
                print(f"❌ Error creating S3 bucket: {e}")
                return False
    
    def create_dynamodb_table(self, table_name):
        """Create DynamoDB table for Terraform state locking"""
        try:
            self.dynamodb_client.create_table(
                TableName=table_name,
                KeySchema=[
                    {
                        'AttributeName': 'LockID',
                        'KeyType': 'HASH'
                    }
                ],
                AttributeDefinitions=[
                    {
                        'AttributeName': 'LockID',
                        'AttributeType': 'S'
                    }
                ],
                BillingMode='PAY_PER_REQUEST'
            )
            
            # Wait for table to be created
            waiter = self.dynamodb_client.get_waiter('table_exists')
            waiter.wait(TableName=table_name)
            
            print(f"✅ DynamoDB table '{table_name}' created successfully")
            return True
            
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceInUseException':
                print(f"⚠️  DynamoDB table '{table_name}' already exists")
                return True
            else:
                print(f"❌ Error creating DynamoDB table: {e}")
                return False


def main():
    print("🚀 Setting up AWS resources for SOC Terraform backend...")
    
    # Initialize AWS setup
    setup = AWSSetup()
    
    # Create resources
    resources_created = []
    
    # S3 buckets for different environments
    buckets = [
        'soc-terraform-state-dev',
        'soc-terraform-state-staging', 
        'soc-terraform-state-prod'
    ]
    
    for bucket in buckets:
        if setup.create_s3_bucket(bucket):
            resources_created.append(f"S3 bucket: {bucket}")
    
    # DynamoDB table for state locking
    table_name = 'soc-terraform-locks'
    if setup.create_dynamodb_table(table_name):
        resources_created.append(f"DynamoDB table: {table_name}")
    
    # Summary
    print("\n📋 Setup Summary:")
    for resource in resources_created:
        print(f"  ✅ {resource}")
    
    print("\n🎉 AWS backend setup completed!")
    print("\nNext steps:")
    print("1. Update your public key in terraform.tfvars files")
    print("2. Review and adjust CIDR blocks and instance types")
    print("3. Run: python scripts/deploy.py --environment dev --action plan")


if __name__ == "__main__":
    main()
