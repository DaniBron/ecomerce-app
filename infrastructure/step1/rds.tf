# Security group for RDS
resource "aws_security_group" "db" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this based on your access needs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "ecommerce_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.rds_instance_type
  username             = var.rds_username
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot  = true
  publicly_accessible     = true

  db_name  = "ecommercedb"

  tags = {
    Name = "ecommerce-db"
  }
}
