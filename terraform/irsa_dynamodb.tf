# --- 1. Politique IAM pour la table DynamoDB Expensy ---
resource "aws_iam_policy" "expensy_dynamodb_policy" {
  name        = "${var.student_name}-expensy-dynamodb-policy"
  description = "Autorise l'application Expensy a lire et ecrire dans sa table DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow" # CORRIGÉ : String au lieu de List
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.expensy_expenses.arn,
          "${aws_dynamodb_table.expensy_expenses.arn}/index/*" # Inclus les index secondaires (GSI)
        ]
      }
    ]
  })
}

# --- 2. Rôle IAM pour Service Account (IRSA) via le module AWS officiel ---
module "expensy_dynamodb_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.student_name}-expensy-dynamodb-role"

  # Associe l'ARN de l'émetteur OIDC du cluster EKS
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:expensy-sa"]
    }
  }

  role_policy_arns = {
    policy = aws_iam_policy.expensy_dynamodb_policy.arn
  }

  tags = {
    Application = "Expensy"
  }
}

# --- 3. Configuration du Provider Kubernetes ---
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = [
      "eks",
      "get-token",
      "--cluster-name", module.eks.cluster_name
    ]
    # Passe explicitement les variables d'environnement si tu utilises un profil spécifique
    env = {
      AWS_PROFILE = "default" # Remplace par le nom de ton profil AWS si nécessaire
    }
  }
}

# --- 4. Service Account Kubernetes avec l'annotation IRSA ---
resource "kubernetes_service_account" "expensy_sa" {
  metadata {
    name      = "expensy-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.expensy_dynamodb_irsa_role.iam_role_arn
    }
  }
}

# --- Outputs ---
output "expensy_service_account_name" {
  description = "Nom du ServiceAccount K8s a utiliser dans le Deployment"
  value       = kubernetes_service_account.expensy_sa.metadata[0].name
}

output "expensy_iam_role_arn" {
  description = "ARN du role IAM associe au ServiceAccount"
  value       = module.expensy_dynamodb_irsa_role.iam_role_arn
}