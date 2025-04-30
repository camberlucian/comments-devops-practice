provider "aws" {
  region = "us-east-2"
}

# VPC setup
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

# Subnet setup
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetA"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetB"
  }
}

# Security Group for EC2 Instance
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "AppSecurityGroup"
  }
}

# Security Group for RDS
resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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
    Name = "DatabaseSecurityGroup"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "PostgresSubnetGroup"
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami                   = "ami-0e38b48473ea57778"
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name              = "comment_app_key_pair"

  tags = {
    Name = "PhoenixAppServer"
  }

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                amazon-linux-extras enable nginx1
                yum install -y nginx git
  EOF
}

# RDS PostgreSQL Database
resource "aws_db_instance" "postgres" {
  identifier              = "comments-app-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "app_user"
  password                = "your-secure-password"
  db_name                 = "comments_app"
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = true
  storage_encrypted       = true
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group.name

  parameter_group_name    = "default.postgres11"

  tags = {
    Name = "PostgresDatabaseInstance"
  }
}
