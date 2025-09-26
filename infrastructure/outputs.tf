# infrastructure/outputs.tf
output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name

}
output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = module.eks.cluster_endpoint

}
# infrastructure/outputs.tf

# ... (keep the other outputs) ...

output "redis_endpoint" {
  description = "Redis cluster endpoint."
  value       = module.elasticache.redis_endpoint
}

output "redis_port" {
  description = "Redis cluster port."
  value       = module.elasticache.redis_port
}