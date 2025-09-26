# infrastructure/modules/elasticache/variables.tf

variable "project_name" {
  description = "The name of the project for tagging."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the ElastiCache cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the ElastiCache cluster."
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "The security group ID of the EKS nodes to allow ingress."
  type        = string
}