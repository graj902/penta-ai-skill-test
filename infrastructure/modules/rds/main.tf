# infrastructure/modules/rds/main.tf

# A DB Subnet Group is a collection of subnets that you can designate for your DB instances in a VPC.
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# The Security Group acts as a virtual firewall for the database.
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic to RDS from EKS nodes"
  vpc_id      = var.vpc_id

  # Ingress rule: Allow PostgreSQL traffic (port 5432) from the EKS nodes' security group.
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  # Egress rule: Allow all outbound traffic (so the DB can get updates, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# The RDS Database Instance
resource "aws_db_instance" "main" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.12"
  instance_class         = "db.t3.micro" # Small instance class for the test
  db_name                = "${replace(var.project_name, "-", "")}db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  
  # Requirement: Multi-AZ failover
  multi_az = true
  
  # Requirement: At-rest encryption
  storage_encrypted = true
}

# The outputs.tf file in `infrastructure/modules/rds/outputs.tf`. This will expose the database connection details for our application to use.


# infrastructure/modules/rds/outputs.tf

