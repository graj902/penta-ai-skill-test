# infrastructure/modules/ecr/variables.tf

variable "repository_name" {
  description = "The name of the ECR repository."
  type        = string
}
