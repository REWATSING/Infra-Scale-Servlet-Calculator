output "security_group_ids" {
  description = "List of security group IDs"
  value = [
    aws_security_group.alb_sg.id,        # ALB Security Group ID
    aws_security_group.bastion_sg.id,     # Public Security Group ID
    aws_security_group.private_sg.id     # Private Security Group ID
  ]
}
