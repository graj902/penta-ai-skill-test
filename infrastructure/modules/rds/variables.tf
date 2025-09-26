# infrastructure/modules/rds/variables.tf

variable "project_name" {
  description = "The name of the project for tagging."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the RDS instance."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the RDS instance."
  type        = list(string)
}

variable "db_username" {
  description = "The username for the RDS database."
  type        = string
  sensitive   = true # Mark this as sensitive so it's not shown in logs
}

variable "db_password" {
  description = "The password for the RDS database."
  type        = string
  sensitive   = true # Mark this as sensitive
}

variable "eks_node_security_group_id" {
  description = "The security group ID of the EKS nodes to allow ingress."
  type        = string
}