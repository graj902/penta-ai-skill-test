# infrastructure/modules/eks/outputs.tf

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "The certificate authority data for the EKS cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
# infrastructure/modules/eks/outputs.tf

# ... (keep the other outputs) ...

output "cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}