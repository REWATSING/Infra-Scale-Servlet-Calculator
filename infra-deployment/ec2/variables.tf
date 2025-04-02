# Input variables for the EC2 module

# variable "ami_id" {
#   description = "AMI ID for the EC2 instance" #we are taking it from data.aws_ami from root
#   type        = string
#   default = "ami-05df2ab3bdf80f440"
# }

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default	  = "t2.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instances are deployed"
  type        = string
}

variable "bastion_sg_id" {
  description = "The ID of the security group for public-facing instances (e.g., bastion host)"
  type        = string
}

variable "private_sg_id" {
  description = "The ID of the security group for private instances (e.g., blue/green environment)"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for the bastion host"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the blue and green instances"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile for EC2 instances to access S3"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default = "us-east-1-key-pair"
}

