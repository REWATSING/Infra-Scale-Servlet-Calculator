# Main configuration for VPC module

# Create VPC
resource "aws_vpc" "client_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Client-VPC"
  }
}


# Create Subnets for Public and Private
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.client_vpc.id
  cidr_block              = var.public_subnet_a_cidr
  map_public_ip_on_launch = true
  availability_zone = var.my_availability_zones[0]  # for first AZ
  tags = {
    Name = "Public-Subnet-A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.client_vpc.id
  cidr_block              = var.public_subnet_b_cidr
  map_public_ip_on_launch = true
  availability_zone = var.my_availability_zones[1] # for second AZ
  tags = {
    Name = "Public-Subnet-B"
  }
}


# Elastic IP For Public Subnets: 
resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

# Associate the EIP with the EC2 Instance
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id = var.bastion_host_id
  allocation_id = aws_eip.bastion_eip.id
}


resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.client_vpc.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.my_availability_zones[0]  # for first AZ
  tags = {
    Name = "Private-Subnet-A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.client_vpc.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.my_availability_zones[1] # for first AZ
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


# Create Route Tables for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.client_igw.id
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


resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public_subnet_a.id
  depends_on = [aws_internet_gateway.client_igw]
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet_b.id
  depends_on = [aws_internet_gateway.client_igw]
}


# Create Route Tables for Private Subnet 1
resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.client_vpc.id
    
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway1.id

  }
}

# Create Route Tables for Private Subnet 2
resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.client_vpc.id
    
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway2.id

  }
}


# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table2.id
}
