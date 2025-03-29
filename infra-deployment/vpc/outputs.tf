output "vpc_id" {
  value = aws_vpc.client_vpc.id
}


output "subnet_ids" {
  value = {
    public  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    private = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  }
}


output "bastion_eip_id" {
	value = aws_eip.bastion_eip.id
}


output "nat_eip_id1" {
  value = aws_eip.nat_eip1.id
}

output "nat_eip_id2" {
  value = aws_eip.nat_eip2.id
}
