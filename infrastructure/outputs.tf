# infrastructure/outputs.tf
output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
  
}
output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = module.eks.cluster_endpoint
  
}