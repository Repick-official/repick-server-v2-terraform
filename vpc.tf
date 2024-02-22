resource "aws_vpc" "repick-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "repick-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.repick-vpc.id

  tags = {
    Name = "repick-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.repick-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "repick-public-rt"
  }
}

resource "aws_subnet" "repick-vpc-public-subnet-1" {
  vpc_id            = aws_vpc.repick-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.repick_vpc_public_subnet_1_availability_zone

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.repick-vpc-public-subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "repick-vpc-public-subnet-2" {
  vpc_id            = aws_vpc.repick-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.repick_vpc_public_subnet_2_availability_zone

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.repick-vpc-public-subnet-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "repick-vpc-private-subnet-1" {
  vpc_id            = aws_vpc.repick-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.repick_vpc_private_subnet_1_availability_zone

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "repick-vpc-private-subnet-2" {
  vpc_id            = aws_vpc.repick-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.repick_vpc_private_subnet_2_availability_zone

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_security_group" "repick-sg" {
  name   = "repick-sg"
  vpc_id = aws_vpc.repick-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.repick_sg_ingress_22_cidr_blocks
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.repick_sg_ingress_80_cidr_blocks
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.repick_sg_ingress_8080_cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.repick_sg_ingress_443_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.repick_sg_engress_cidr_blocks
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "repick-rds-sg" {
  name   = "repick-rds-sg"
  vpc_id = aws_vpc.repick-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.repick-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.repick_sg_engress_cidr_blocks
  }

  lifecycle {
    create_before_destroy = true
  }

}


output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.repick-vpc.id
}

output "public_subnet_1_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.repick-vpc-public-subnet-1.id
}

output "public_subnet_2_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.repick-vpc-public-subnet-2.id
}

output "private_subnet_1_id" {
  description = "The ID of the private subnet 1"
  value       = aws_subnet.repick-vpc-private-subnet-1.id
}

output "private_subnet_2_id" {
  description = "The ID of the private subnet 2"
  value       = aws_subnet.repick-vpc-private-subnet-2.id
}
