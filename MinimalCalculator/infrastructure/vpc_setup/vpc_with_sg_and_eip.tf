resource "aws_vpc" "client_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Client-VPC-Rewat"
  }
}

# Create subnets for availability zones us-east-1a and us-east-1b
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.client_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.client_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-B"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.client_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-Subnet-A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.client_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-Subnet-B"
  }
}

# Create Internet Gateway for internet access
resource "aws_internet_gateway" "client_igw" {
  vpc_id = aws_vpc.client_vpc.id
  tags = {
    Name = "Client-Internet-Gateway"
  }
}

# Create Route Tables for Public and Private Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.client_igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.client_vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a NAT Gateway for Private Subnet
resource "aws_eip" "nat_eip" {
  domain = "vpc" # Updated to use 'domain'
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  depends_on = [aws_internet_gateway.client_igw]
}

# Create a Route for Private Subnets to route traffic via NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group for Public Subnets (SSH, HTTP, HTTPS access)
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.client_vpc.id

  # Allow SSH, HTTP, HTTPS
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-SG"
  }
}

# Security Group for Private Subnets (SSH, and Private Access)
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.client_vpc.id

  # Allow SSH access from public subnet only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet_a.cidr_block, aws_subnet.public_subnet_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-SG"
  }
}

output "vpc_id" {
  value = aws_vpc.client_vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "security_group_ids" {
  value = [aws_security_group.public_sg.id, aws_security_group.private_sg.id]
}

output "eip_id" {
  value = aws_eip.nat_eip.id
}
