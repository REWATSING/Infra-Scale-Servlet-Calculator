#!/bin/bash

# Create the directory structure
mkdir -p infrastructure/EC2_setup

# Navigate to the EC2_setup directory
cd infrastructure/EC2_setup || exit

# Create the main.tf file
cat > main.tf <<EOF
provider "aws" {
  region = "us-east-1"
}

# Public EC2 instance (Bastion)
resource "aws_instance" "public_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  security_group_ids = [
    var.public_sg_id
  ]

  tags = {
    Name        = "Bastion"
    Environment = "Production"
  }
}

# Private EC2 instance in AZ1
resource "aws_instance" "private_instance_az1" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id_az1
  key_name      = var.key_name

  security_group_ids = [
    var.private_sg_id
  ]

  tags = {
    Name        = "Web-Server-1"
    Environment = "Production"
  }
}

# Private EC2 instance in AZ2
resource "aws_instance" "private_instance_az2" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id_az2
  key_name      = var.key_name

  security_group_ids = [
    var.private_sg_id
  ]

  tags = {
    Name        = "Web-Server-2"
    Environment = "Production"
  }
}
EOF

# Create the variables.tf file
cat > variables.tf <<EOF
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "public_sg_id" {
  description = "Security Group ID for the public EC2 instance"
  type        = string
}

variable "private_sg_id" {
  description = "Security Group ID for the private EC2 instances"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID for the public EC2 instance"
  type        = string
}

variable "private_subnet_id_az1" {
  description = "Subnet ID for the private EC2 instance in AZ1"
  type        = string
}

variable "private_subnet_id_az2" {
  description = "Subnet ID for the private EC2 instance in AZ2"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will be launched"
  type        = string
}
EOF

# Create the outputs.tf file
cat > outputs.tf <<EOF
output "public_instance_id" {
  value = aws_instance.public_instance.id
}

output "public_instance_public_ip" {
  value = aws_instance.public_instance.public_ip
}

output "private_instance_az1_id" {
  value = aws_instance.private_instance_az1.id
}

output "private_instance_az1_private_ip" {
  value = aws_instance.private_instance_az1.private_ip
}

output "private_instance_az2_id" {
  value = aws_instance.private_instance_az2.id
}

output "private_instance_az2_private_ip" {
  value = aws_instance.private_instance_az2.private_ip
}
EOF

# Create the terraform.tfvars file
cat > terraform.tfvars <<EOF
ami_id              = "ami-083710e964ef3e09d"
key_name            = "keypair2" 
vpc_id              = "vpc-08a26beb2166bc31b"
public_sg_id        = "sg-0283ca502d8968b43"
private_sg_id       = "sg-0019c03292d326d7c"
public_subnet_id    = "subnet-01c597e20b56e9af1"
private_subnet_id_az1 = "subnet-013a07a6cba519663"
private_subnet_id_az2 = "subnet-0e8b9dada069e29e3"
EOF

echo "EC2_setup folder and files created successfully under infrastructure/"
