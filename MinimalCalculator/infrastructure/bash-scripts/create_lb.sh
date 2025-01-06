#!/bin/bash

# Navigate to the infrastructure/aws_lb_setup directory
cd "."

# Initialize Terraform (if not already done)
terraform init

# Run the Terraform plan to review changes
terraform plan -var-file=terraform.tfvars

# Apply the changes to create the Load Balancer and Target Group
terraform apply -var-file=terraform.tfvars -auto-approve

# Optionally, output the Load Balancer DNS name for testing
echo "ALB DNS: $(terraform output -raw lb_dns_name)"
