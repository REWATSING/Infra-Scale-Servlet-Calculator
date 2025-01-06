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
