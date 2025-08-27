# SOC Infrastructure Makefile

.PHONY: help init plan apply destroy validate format clean setup-backend

# Default environment
ENV ?= dev

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)SOC Infrastructure Management$(NC)"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  $(YELLOW)make plan ENV=dev$(NC)      # Plan dev environment"
	@echo "  $(YELLOW)make apply ENV=prod$(NC)    # Apply prod environment"
	@echo "  $(YELLOW)make destroy ENV=dev$(NC)   # Destroy dev environment"

setup-backend: ## Set up AWS backend resources (S3 + DynamoDB)
	@echo "$(BLUE)Setting up AWS backend resources...$(NC)"
	python scripts/setup_backend.py

init: ## Initialize Terraform for specified environment
	@echo "$(BLUE)Initializing Terraform for $(ENV) environment...$(NC)"
	cd environments/$(ENV) && terraform init

validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration for $(ENV)...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action validate --skip-init

format: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	terraform fmt -recursive .

plan: ## Create Terraform plan
	@echo "$(BLUE)Creating Terraform plan for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action plan

apply: ## Apply Terraform configuration
	@echo "$(BLUE)Applying Terraform configuration for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action apply

apply-auto: ## Apply Terraform configuration with auto-approve
	@echo "$(YELLOW)Auto-applying Terraform configuration for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action apply --auto-approve

destroy: ## Destroy infrastructure
	@echo "$(RED)Destroying infrastructure for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action destroy

destroy-auto: ## Destroy infrastructure with auto-approve
	@echo "$(RED)Auto-destroying infrastructure for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action destroy --auto-approve

output: ## Show Terraform outputs
	@echo "$(BLUE)Showing outputs for $(ENV) environment...$(NC)"
	python scripts/deploy.py --environment $(ENV) --action output --skip-init

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	find . -name "*.tfplan*" -delete
	find . -name ".terraform.lock.hcl" -delete
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

check-aws: ## Check AWS credentials and connectivity
	@echo "$(BLUE)Checking AWS credentials...$(NC)"
	aws sts get-caller-identity

lint: ## Run Terraform linting
	@echo "$(BLUE)Running Terraform linting...$(NC)"
	terraform fmt -check=true -recursive .
	@echo "$(GREEN)Linting completed$(NC)"

# Development workflow shortcuts
dev-plan: ## Quick plan for dev environment
	$(MAKE) plan ENV=dev

dev-apply: ## Quick apply for dev environment
	$(MAKE) apply ENV=dev

dev-destroy: ## Quick destroy for dev environment
	$(MAKE) destroy ENV=dev

# Production workflow shortcuts
prod-plan: ## Quick plan for prod environment
	$(MAKE) plan ENV=prod

prod-apply: ## Quick apply for prod environment
	$(MAKE) apply ENV=prod

prod-destroy: ## Quick destroy for prod environment
	$(MAKE) destroy ENV=prod
