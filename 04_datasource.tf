data "aws_caller_identity" "current" {}

# Find a certificate that is issued
data "aws_acm_certificate" "existing_cert" {
  domain      = var.acm_cert_host
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "my_domain" {
  name         = var.domain_name
  private_zone = false
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_ecr_repository" "app_repo" {
  name = "${lower(var.project_name)}-${lower(var.project_env)}-repo"
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-south-1.s3"
}
