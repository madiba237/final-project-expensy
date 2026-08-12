terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Dynamo table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "alain-expensy-tf-locks"
  billing_mode = "PAY_PER_REQUEST" # Mode à la demande (économique et idéal pour le locking)
  hash_key     = "LockID"         # /!\ La clé d'hachage OBLIGATOIRE demandée par le backend S3 de Terraform

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

# S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "alain-expensy-tf-state-bucket"
  force_destroy = false # Empêche la suppression accidentelle si le bucket contient des données

  lifecycle {
    prevent_destroy = true # Sécurité supplémentaire contre le terraform destroy
  }
}

# Activation du versioning pour conserver l'historique des états et pouvoir restaurer en cas de corruption
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement côté serveur par défaut (AES256 / SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Blocage strict de tout accès public au bucket S3
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}