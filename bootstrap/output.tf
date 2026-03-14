output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app_repo.name
}

output "ecr_repository_url" {
  description = "ECR repository URL used to push Docker images"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "terraform_state_bucket_name" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}
