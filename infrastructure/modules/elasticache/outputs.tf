# infrastructure/modules/elasticache/outputs.tf

output "redis_endpoint" {
  description = "The connection endpoint for the Redis replication group."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "The port for the Redis replication group."
  value       = aws_elasticache_replication_group.main.port
}