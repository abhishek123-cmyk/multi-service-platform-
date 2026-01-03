provider "aws" {
  region = var.aws_region
}

# 1️⃣ Create ECR repo
resource "aws_ecr_repository" "node1" {
  name = "node-service-1"
}

# 2️⃣ IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com" }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
