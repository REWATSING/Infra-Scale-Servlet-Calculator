output "bastion_host_id" {
  value = aws_instance.bastion_host.id
}

output "blue_launch_template_id" {
  value = aws_launch_template.blue_launch_template.id
}

output "green_launch_template_id" {
  value = aws_launch_template.green_launch_template.id  
}