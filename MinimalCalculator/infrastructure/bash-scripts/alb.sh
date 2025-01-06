#!/bin/bash

# Define the base directory for your infrastructure setup
BASE_DIR="$HOME/Java-DesktopApp-Calculator/MinimalCalculator/infrastructure"

# Create the aws_lb_setup folder if it doesn't exist
mkdir -p "$BASE_DIR/aws_lb_setup"

# Navigate to the new folder
cd "$BASE_DIR/aws_lb_setup"

# Create variables.tf
cat <<EOL > variables.tf
# aws_lb_setup/variables.tf

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "ec2_instance_ids" {
  description = "IDs of the EC2 instances to attach to the target group"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}
EOL

# Create terraform.tfvars
cat <<EOL > terraform.tfvars
# aws_lb_setup/terraform.tfvars

vpc_id               = "vpc-xxxxxxxx"  # Your VPC ID
public_subnet_ids    = ["subnet-xxxxxx", "subnet-yyyyyy"]  # Your public subnet IDs
private_subnet_ids   = ["subnet-zzzzzz", "subnet-aaaaaa"]  # Your private subnet IDs
ec2_instance_ids     = ["i-xxxxxxxxxxxx", "i-yyyyyyyyyyyy"]  # Your EC2 instance IDs
region               = "us-east-1"  # AWS region
EOL

# Create main.tf
cat <<EOL > main.tf
# aws_lb_setup/main.tf

provider "aws" {
  region = var.region
}

# Create a new security group for the ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# Create the Application Load Balancer
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]  # Use new ALB security group
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb"
  }
}

# Create the Target Group
resource "aws_lb_target_group" "main" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# Create the HTTP listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach EC2 instances to the target group
resource "aws_lb_target_group_attachment" "instance_attachment" {
  count             = length(var.ec2_instance_ids)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = element(var.ec2_instance_ids, count.index)
  port             = 80
}

# Allow inbound traffic from the ALB security group to private instances
resource "aws_security_group_rule" "allow_alb_to_instances" {
  security_group_id = var.existing_sg_id  # Use existing security group for private instances
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}
EOL

# Create output.tf (optional)
cat <<EOL > output.tf
# aws_lb_setup/output.tf

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
EOL

# Create create_lb.sh (bash script to apply configuration)
cat <<EOL > create_lb.sh
#!/bin/bash

# Navigate to the infrastructure/aws_lb_setup directory
cd "$(dirname "$0")"

# Initialize Terraform (if not already done)
terraform init

# Run the Terraform plan to review changes
terraform plan -var-file=terraform.tfvars

# Apply the changes to create the Load Balancer and Target Group
terraform apply -var-file=terraform.tfvars -auto-approve

# Optionally, output the Load Balancer DNS name for testing
echo "ALB DNS: \$(terraform output -raw lb_dns_name)"
EOL

# Make create_lb.sh executable
chmod +x create_lb.sh

echo "Folder structure and files for AWS Load Balancer setup created successfully!"
