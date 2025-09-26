# infrastructure/modules/elasticache/main.tf

# An ElastiCache Subnet Group is a collection of subnets for your cluster.
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# The Security Group acts as a virtual firewall for the Redis cluster.
resource "aws_security_group" "redis_sg" {
  name        = "${var.project_name}-redis-sg"
  description = "Allow traffic to Redis from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

# THIS IS THE CORRECT RESOURCE FOR ENCRYPTED REDIS
resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${replace(var.project_name, "_", "-")}-redis-rg"
  description                   = "Replication group for the project"
  node_type                     = "cache.t3.micro"
  engine                        = "redis"
  engine_version                = "7.1"
  port                          = 6379
  
  # Creates a primary and a replica for high availability
  num_node_groups               = 1
  replicas_per_node_group       = 1
  
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  automatic_failover_enabled    = true

  # Requirement: At-rest and in-transit encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
}