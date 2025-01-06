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

variable "existing_sg_id" {
  description = "The ID of the existing security group to allow inbound traffic from ALB"
  type        = string
}
