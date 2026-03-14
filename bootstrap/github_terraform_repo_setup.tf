resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsWorkflowPolicy"
  description = "Policy for GitHub Actions to manage infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateAccess"
        Effect = "Allow"
        Action = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
        Resource = [
          "arn:aws:s3:::${var.terraform_state_bucket_name}",
          "arn:aws:s3:::${var.terraform_state_bucket_name}/*"
        ]
      },
      {
        Sid    = "TerraformLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        # Dynamically uses your account ID
        Resource = "arn:aws:dynamodb:ap-south-1:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table}"
      },
      {
        Sid    = "FullAccessToServices"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "s3:*",
          "acm:*",
          "route53:*",
          "logs:*",
          "iam:*",
          "codedeploy:*",
          "cloudfront:*",
          "ecr:*",
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        Sid      = "STSAccess"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsWorkflowRole"

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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_terraform_repo}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

