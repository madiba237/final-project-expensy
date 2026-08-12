output "docdb_endpoint" {
  description = "Endpoint de la base MongoDB / DocumentDB"
  value       = aws_docdb_cluster.docdb.endpoint
}

output "redis_endpoint" {
  description = "Endpoint du cluster ElastiCache Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}