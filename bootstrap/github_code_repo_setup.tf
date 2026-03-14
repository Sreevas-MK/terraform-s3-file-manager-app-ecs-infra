# IAM Policy for GitHub Actions (ECR)
resource "aws_iam_policy" "github_ecr_policy" {
  name        = "GitHubActionsECRPolicy"
  description = "Policy for GitHub Actions to push/pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories"
        ]
        Resource = [
          aws_ecr_repository.app_repo.arn,
          "${aws_ecr_repository.app_repo.arn}/*"
        ]
      }
    ]
  })
}


# POLICY 2: ECS (The one you need to add)
resource "aws_iam_policy" "github_ecs_policy" {
  name = "GitHubActionsECSPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:UpdateService", "ecs:DescribeServices"]
        Resource = "*" # Or restrict to your service ARN
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*" # Required to 'pass' the task roles to ECS
      }
    ]
  })
}

# IAM Role for GitHub OIDC (ECR only)
resource "aws_iam_role" "github_code_repo_role" {
  name = "github-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_code_repo}:*"
          }
        }
      }
    ]
  })
}

# Attach ECR policy to GitHub role
resource "aws_iam_role_policy_attachment" "attach_github_ecr_policy" {
  role       = aws_iam_role.github_code_repo_role.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_github_ecs_policy" {
  role       = aws_iam_role.github_code_repo_role.name
  policy_arn = aws_iam_policy.github_ecs_policy.arn
}
