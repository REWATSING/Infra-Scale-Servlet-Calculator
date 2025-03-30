variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A map of subnet IDs (public and private)"
  type        = map(list(string))
}

variable "alb_sg_id" {
  description = "ALB Security Group ID"
  type        = string
}


variable "acm_certificate_arn" {
  description = "The ARN of the SSL certificate from ACM"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the blue and green instances"
  type        = list(string)
}

variable "blue_launch_template_id" {
  description = "ID of the AWS Launch Template"
  type        = string
}

variable "green_launch_template_id" {
  description = "ID of the AWS Launch Template"
  type        = string
}
