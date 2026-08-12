variable "docdb_password" {
  description = "Mot de passe master pour DocumentDB (MongoDB)"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Mot de passe d'authentification Redis (AUTH token)"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "eu-east-1"
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "alain-expensy-eks-cluster"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "alain-dev"
}

