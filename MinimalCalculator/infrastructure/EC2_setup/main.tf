provider "aws" {
  region = "us-east-1"
}

# Public EC2 instance (Bastion)
resource "aws_instance" "public_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.public_sg_id
  ]

  tags = {
    Name        = "Bastion"
    Environment = "Production"
  }
}

# Private EC2 instance in AZ1
resource "aws_instance" "private_instance_az1" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id_az1
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.private_sg_id
  ]

  tags = {
    Name        = "Web-Server-1"
    Environment = "Production"
  }
}

# Private EC2 instance in AZ2
resource "aws_instance" "private_instance_az2" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id_az2
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.private_sg_id
  ]

  tags = {
    Name        = "Web-Server-2"
    Environment = "Production"
  }
}
