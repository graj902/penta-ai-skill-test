# infrastructure/modules/eks/variables.tf

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS nodes."
  type        = list(string)
}