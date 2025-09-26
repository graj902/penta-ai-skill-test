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
# infrastructure/variables.tf

# ... (keep the other variables) ...

variable "db_username" {
  description = "Database admin username"
  type        = string
  default     = "adminuser"
  sensitive   = true
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  default     = "YourSecurePassword123!" # In a real project, use a secret manager!
  sensitive   = true
}
