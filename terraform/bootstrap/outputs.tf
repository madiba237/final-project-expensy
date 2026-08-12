output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Nom du bucket S3 créé pour le state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.id
  description = "Nom de la table DynamoDB créée pour le lock"
}