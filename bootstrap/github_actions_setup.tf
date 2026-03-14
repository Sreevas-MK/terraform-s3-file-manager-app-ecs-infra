# This configures variables in your INFRA repo
resource "github_actions_variable" "infra_aws_account_id" {
  repository    = var.github_terraform_repo
  variable_name = "AWS_ACCOUNT_ID"
  value         = data.aws_caller_identity.current.account_id
}

resource "github_actions_variable" "infra_aws_region" {
  repository    = var.github_terraform_repo
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

# OPTIONAL: Configure the CODE repo directly with the ECR URL
resource "github_actions_variable" "code_ecr_url" {
  repository    = var.github_code_repo
  variable_name = "ECR_REPOSITORY_URL"
  value         = aws_ecr_repository.app_repo.repository_url
}
