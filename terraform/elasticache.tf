resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.cluster_name}-redis-subnet-group"
  description = "Subnet group pour Redis    "
  subnet_ids  = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.cluster_name}-redis"
  description          = "Cluster Redis pour Expensy"
  node_type            = "cache.t3.medium" # Economique pour démarrer
  num_cache_clusters            = 1
  parameter_group_name          = "default.redis7"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  transit_encryption_enabled    = true
  auth_token                    = var.redis_password
}