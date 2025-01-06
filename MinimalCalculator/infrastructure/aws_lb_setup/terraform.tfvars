# aws_lb_setup/terraform.tfvars

vpc_id             = "vpc-08a26beb2166bc31b"                                  # Your VPC ID
public_subnet_ids  = ["subnet-01c597e20b56e9af1", "subnet-079c4c6a2fda89573"]                             # Your public subnet IDs
private_subnet_ids = ["subnet-013a07a6cba519663", "subnet-0e8b9dada069e29e3"] # Your private subnet IDs
ec2_instance_ids   = ["i-0a3aaab252353fb00", "i-098dd743488fc0982"]           # Your EC2 instance IDs
region             = "us-east-1"                                              # AWS region
existing_sg_id     = "sg-0019c03292d326d7c"
