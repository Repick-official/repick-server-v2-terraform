resource "aws_iam_openid_connect_provider" "github_actions_idp" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [var.github_thumbprint]

}

resource "aws_iam_role" "github_actions_role" {
  name        = "GitHubActions-AssumeRoleWithAction"
  description = "IAM role to be assumed by GitHub Actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_idp.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository_name}:ref:refs/heads/${var.github_branch_name}",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for Github Actions"
  value       = aws_iam_role.github_actions_role.arn
}