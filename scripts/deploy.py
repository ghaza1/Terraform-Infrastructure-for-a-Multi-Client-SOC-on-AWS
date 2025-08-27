#!/usr/bin/env python3
"""
SOC Infrastructure Deployment Script

This script automates the deployment of the SOC infrastructure using Terraform.
It provides functionality for planning, applying, and destroying infrastructure
across different environments (dev, staging, prod).

Usage:
    python deploy.py --environment dev --action plan
    python deploy.py --environment prod --action apply
    python deploy.py --environment dev --action destroy
"""

import argparse
import os
import subprocess
import sys
import json
import time
from datetime import datetime


class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


class TerraformDeployer:
    """Terraform deployment automation class"""
    
    def __init__(self, environment, working_dir=None):
        self.environment = environment
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.project_root = os.path.dirname(self.script_dir)
        self.env_dir = os.path.join(self.project_root, 'environments', environment)
        self.working_dir = working_dir or self.env_dir
        
        # Validate environment
        if not os.path.exists(self.env_dir):
            raise ValueError(f"Environment '{environment}' not found at {self.env_dir}")
    
    def log(self, message, color=Colors.OKBLUE):
        """Log message with timestamp and color"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"{color}[{timestamp}] {message}{Colors.ENDC}")
    
    def log_success(self, message):
        """Log success message"""
        self.log(f"✅ {message}", Colors.OKGREEN)
    
    def log_warning(self, message):
        """Log warning message"""
        self.log(f"⚠️  {message}", Colors.WARNING)
    
    def log_error(self, message):
        """Log error message"""
        self.log(f"❌ {message}", Colors.FAIL)
    
    def run_command(self, command, check=True, capture_output=False):
        """Run shell command with proper error handling"""
        self.log(f"Running: {command}")
        
        try:
            if capture_output:
                result = subprocess.run(
                    command, 
                    shell=True, 
                    cwd=self.working_dir,
                    capture_output=True, 
                    text=True, 
                    check=check
                )
                return result
            else:
                result = subprocess.run(
                    command, 
                    shell=True, 
                    cwd=self.working_dir, 
                    check=check
                )
                return result
        except subprocess.CalledProcessError as e:
            self.log_error(f"Command failed with exit code {e.returncode}")
            if hasattr(e, 'stderr') and e.stderr:
                self.log_error(f"Error output: {e.stderr}")
            raise
    
    def check_prerequisites(self):
        """Check if required tools are installed"""
        self.log("Checking prerequisites...")
        
        # Check Terraform
        try:
            result = self.run_command("terraform version", capture_output=True)
            terraform_version = result.stdout.split('\n')[0]
            self.log_success(f"Terraform found: {terraform_version}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log_error("Terraform not found. Please install Terraform.")
            return False
        
        # Check AWS CLI
        try:
            result = self.run_command("aws --version", capture_output=True)
            aws_version = result.stdout.strip()
            self.log_success(f"AWS CLI found: {aws_version}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log_warning("AWS CLI not found. Make sure AWS credentials are configured.")
        
        # Check if terraform.tfvars exists
        tfvars_path = os.path.join(self.env_dir, "terraform.tfvars")
        if not os.path.exists(tfvars_path):
            self.log_error(f"terraform.tfvars not found at {tfvars_path}")
            return False
        
        self.log_success("Prerequisites check completed")
        return True
    
    def terraform_init(self):
        """Initialize Terraform"""
        self.log("Initializing Terraform...")
        self.run_command("terraform init")
        self.log_success("Terraform initialized")
    
    def terraform_plan(self, save_plan=True):
        """Run Terraform plan"""
        self.log("Running Terraform plan...")
        
        plan_file = f"tfplan-{self.environment}-{int(time.time())}"
        command = f"terraform plan -var-file=terraform.tfvars"
        
        if save_plan:
            command += f" -out={plan_file}"
        
        self.run_command(command)
        self.log_success("Terraform plan completed")
        
        if save_plan:
            return plan_file
        return None
    
    def terraform_apply(self, plan_file=None, auto_approve=False):
        """Apply Terraform configuration"""
        self.log("Applying Terraform configuration...")
        
        if plan_file and os.path.exists(os.path.join(self.working_dir, plan_file)):
            command = f"terraform apply {plan_file}"
        else:
            command = "terraform apply -var-file=terraform.tfvars"
            if auto_approve:
                command += " -auto-approve"
        
        self.run_command(command)
        self.log_success("Terraform apply completed")
    
    def terraform_destroy(self, auto_approve=False):
        """Destroy Terraform-managed infrastructure"""
        self.log("Destroying Terraform infrastructure...")
        
        command = "terraform destroy -var-file=terraform.tfvars"
        if auto_approve:
            command += " -auto-approve"
        
        self.run_command(command)
        self.log_success("Terraform destroy completed")
    
    def terraform_output(self):
        """Get Terraform outputs"""
        self.log("Getting Terraform outputs...")
        
        try:
            result = self.run_command("terraform output -json", capture_output=True)
            outputs = json.loads(result.stdout)
            
            self.log_success("Infrastructure outputs:")
            for key, value in outputs.items():
                if 'value' in value:
                    print(f"  {key}: {value['value']}")
            
            return outputs
        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            self.log_warning("Could not retrieve outputs")
            return {}
    
    def validate_configuration(self):
        """Validate Terraform configuration"""
        self.log("Validating Terraform configuration...")
        self.run_command("terraform validate")
        self.log_success("Configuration is valid")
    
    def format_configuration(self):
        """Format Terraform configuration files"""
        self.log("Formatting Terraform configuration...")
        self.run_command("terraform fmt -recursive")
        self.log_success("Configuration formatted")


def main():
    """Main deployment script"""
    parser = argparse.ArgumentParser(
        description="SOC Infrastructure Deployment Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python deploy.py --environment dev --action plan
  python deploy.py --environment prod --action apply --auto-approve
  python deploy.py --environment dev --action destroy
  python deploy.py --environment staging --action validate
        """
    )
    
    parser.add_argument(
        '--environment', '-e',
        required=True,
        choices=['dev', 'staging', 'prod'],
        help='Target environment'
    )
    
    parser.add_argument(
        '--action', '-a',
        required=True,
        choices=['plan', 'apply', 'destroy', 'validate', 'format', 'output'],
        help='Action to perform'
    )
    
    parser.add_argument(
        '--auto-approve',
        action='store_true',
        help='Skip interactive approval for apply/destroy'
    )
    
    parser.add_argument(
        '--skip-init',
        action='store_true',
        help='Skip terraform init'
    )
    
    args = parser.parse_args()
    
    try:
        # Initialize deployer
        deployer = TerraformDeployer(args.environment)
        
        # Check prerequisites
        if not deployer.check_prerequisites():
            sys.exit(1)
        
        # Change to environment directory
        os.chdir(deployer.env_dir)
        deployer.working_dir = deployer.env_dir
        
        # Initialize Terraform (unless skipped)
        if not args.skip_init:
            deployer.terraform_init()
        
        # Perform requested action
        if args.action == 'validate':
            deployer.validate_configuration()
        
        elif args.action == 'format':
            deployer.format_configuration()
        
        elif args.action == 'plan':
            deployer.terraform_plan()
        
        elif args.action == 'apply':
            # Always plan before apply for safety
            plan_file = deployer.terraform_plan()
            
            # Confirm apply unless auto-approved
            if not args.auto_approve:
                confirm = input(f"\nDo you want to apply these changes to {args.environment}? (yes/no): ")
                if confirm.lower() != 'yes':
                    deployer.log_warning("Apply cancelled by user")
                    sys.exit(0)
            
            deployer.terraform_apply(plan_file, args.auto_approve)
            deployer.terraform_output()
        
        elif args.action == 'destroy':
            # Confirm destroy unless auto-approved
            if not args.auto_approve:
                confirm = input(f"\n⚠️  Are you sure you want to DESTROY all resources in {args.environment}? (yes/no): ")
                if confirm.lower() != 'yes':
                    deployer.log_warning("Destroy cancelled by user")
                    sys.exit(0)
            
            deployer.terraform_destroy(args.auto_approve)
        
        elif args.action == 'output':
            deployer.terraform_output()
        
        deployer.log_success(f"Action '{args.action}' completed successfully for environment '{args.environment}'")
    
    except Exception as e:
        print(f"{Colors.FAIL}❌ Deployment failed: {str(e)}{Colors.ENDC}")
        sys.exit(1)


if __name__ == "__main__":
    main()
