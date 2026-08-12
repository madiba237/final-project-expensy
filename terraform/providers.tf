terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "alain-expensy-tf-state-bucket"  # Nom unique de votre bucket S3
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true       # Table DynamoDB pour le state locking
  }


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