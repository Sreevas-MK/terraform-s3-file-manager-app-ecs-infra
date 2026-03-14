locals {
  # List of all repositories that need these AWS variables
  target_repos = [var.github_terraform_repo, var.github_code_repo]
}


# This configures variables in your INFRA repo
resource "github_actions_variable" "aws_account_id" {
  for_each      = toset(local.target_repos)
  repository    = each.value
  variable_name = "AWS_ACCOUNT_ID"
  value         = data.aws_caller_identity.current.account_id
}

resource "github_actions_variable" "aws_region" {
  for_each      = toset(local.target_repos)
  repository    = each.value
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

resource "github_actions_variable" "code_repo_name" {
  repository    = var.github_terraform_repo
  variable_name = "CODE_REPO"
  value         = var.github_code_repo
}

resource "github_actions_variable" "code_repo_user" {
  repository    = var.github_terraform_repo
  variable_name = "CODE_REPO_USERNAME"
  value         = var.github_username
}

# This sends the Secret Token to the INFRA repo so it can trigger the CODE repo
resource "github_actions_secret" "app_repo_access" {
  repository      = var.github_terraform_repo
  secret_name     = "S3_APP_CODE_REPO_ACCESS"
  plaintext_value = var.github_token
}

resource "github_actions_variable" "ecr_name" {
  for_each      = toset(local.target_repos)
  repository    = each.value
  variable_name = "ECR_REPOSITORY_NAME"
  value         = aws_ecr_repository.app_repo.name
}

resource "github_actions_variable" "app_repo_ecs_name" {
  repository      = var.github_code_repo
  variable_name   = "CLUSTER_NAME"
  value = "${var.project_name}-${var.project_env}-cluster"
}

resource "github_actions_variable" "app_repo_service_name" {
  repository      = var.github_code_repo
  variable_name   = "SERVICE_NAME"
  value = var.project_name
}

