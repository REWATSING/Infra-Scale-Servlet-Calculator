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
