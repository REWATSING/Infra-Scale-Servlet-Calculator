output "bastion_host_id" {
  value = aws_instance.bastion_host.id
}

output "aws_launch_template_id" {
  value = aws_launch_template.app_launch_template.id
}

