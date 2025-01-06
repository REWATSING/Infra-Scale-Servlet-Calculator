#!/bin/bash

# Create the infrastructure directory
mkdir -p infrastructure

# Create main.tf file
cat <<EOL > infrastructure/main.tf
provider "aws" {
  region = "us-east-1"
}

# Define EC2 Instance Resource for Blue Environment
resource "aws_instance" "blue_instance" {
  ami           = "ami-083710e964ef3e09d"  # Replace with your golden AMI ID
  instance_type = "t2.micro"
  tags = {
    Name = "BlueEnvironment"
  }
}

# Define EC2 Instance Resource for Green Environment
resource "aws_instance" "green_instance" {
  ami           = "ami-083710e964ef3e09d"  # Replace with your golden AMI ID
  instance_type = "t2.micro"
  tags = {
    Name = "GreenEnvironment"
  }
}

# Create an Elastic Load Balancer (ELB)
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups   = ["sg-xxxxxxxx"]  # Replace with your security group ID
  subnets            = ["subnet-xxxxxxxx"]  # Replace with your subnet IDs

  enable_deletion_protection = false
}

# Add listeners for the ELB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}

# Register Blue Environment EC2 with the ELB
resource "aws_lb_target_group" "blue_target_group" {
  name     = "blue-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-xxxxxxxx"  # Replace with your VPC ID

  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

# Register Green Environment EC2 with the ELB
resource "aws_lb_target_group" "green_target_group" {
  name     = "green-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-xxxxxxxx"  # Replace with your VPC ID

  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}
EOL

# Create variables.tf file
cat <<EOL > infrastructure/variables.tf
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type for EC2"
  type        = string
  default     = "t2.micro"
}
EOL

# Create outputs.tf file
cat <<EOL > infrastructure/outputs.tf
output "blue_instance_ip" {
  value = aws_instance.blue_instance.public_ip
}

output "green_instance_ip" {
  value = aws_instance.green_instance.public_ip
}

output "elb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
EOL

# Create terraform.tfvars file
cat <<EOL > infrastructure/terraform.tfvars
aws_region     = "us-east-1"
instance_type  = "t2.micro"
EOL

echo "Terraform infrastructure files have been created in the 'infrastructure' directory."
