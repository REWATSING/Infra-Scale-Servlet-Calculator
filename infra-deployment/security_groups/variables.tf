variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A map of subnet IDs (public and private)"
  type        = map(list(string))
}
