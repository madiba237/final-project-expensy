# Redis 
# --- Groupe de sous-réseaux privés pour ElastiCache ---
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.student_name}-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.student_name}-redis-subnet-group"
    Application = "Expensy"
  }
}

# --- Cluster ElastiCache Redis ---
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.student_name}-expensy-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro" # Économique pour un environnement de dev/test
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis_sg.id]

  tags = {
    Name        = "${var.student_name}-expensy-redis"
    Application = "Expensy"
  }
}

# --- Outputs pour la connexion depuis Kubernetes ---
output "redis_endpoint" {
  description = "Adresse Endpoint de connexion Redis"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Port de connexion Redis"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}


# DynamoDB

# --- Table DynamoDB pour Expensy ---
resource "aws_dynamodb_table" "expensy_expenses" {
  name         = "expensy-expenses-${var.student_name}"
  billing_mode = "PAY_PER_REQUEST" # Mode On-Demand : pas de coût fixe, vous ne payez qu'à l'usage

  # Clé primaire composée (Clé de partition + Clé de tri)
  hash_key  = "userId"    # Identifiant de l'utilisateur
  range_key = "expenseId" # Identifiant unique de la dépense

  attribute {
    name = "userId"
    type = "S" # String
  }

  attribute {
    name = "expenseId"
    type = "S" # String
  }

  # Index secondaire global (GSI) pour requêter rapidement par date
  attribute {
    name = "createdAt"
    type = "S"
  }

  global_secondary_index {
    name            = "CreatedAtIndex"
    hash_key        = "userId"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true # Sauvegardes continues actives
  }

  server_side_encryption {
    enabled = true # Chiffrement au repos par défaut
  }

  tags = {
    Name        = "expensy-expenses-${var.student_name}"
    Application = "Expensy"
  }
}

# --- Output de la table ---
output "dynamodb_table_name" {
  description = "Nom de la table DynamoDB"
  value       = aws_dynamodb_table.expensy_expenses.name
}

output "dynamodb_table_arn" {
  description = "ARN de la table DynamoDB pour la politique IAM EKS"
  value       = aws_dynamodb_table.expensy_expenses.arn
}