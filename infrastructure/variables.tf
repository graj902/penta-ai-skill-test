# infrastructure/variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "penta-ai-test"
}
