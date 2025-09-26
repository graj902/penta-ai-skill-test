variable "aws_region" {
  description = "AWS region to deploy the resource"
  type        = string
}
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string

}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

}
variable "project_name" {
  description = "Project name to tag resources"
  type        = string

}