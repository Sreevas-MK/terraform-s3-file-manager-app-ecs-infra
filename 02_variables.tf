variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "zones" {
  description = "AWS region"
  type        = list(string)
  default     = ["ap-south-1b", "ap-south-1a", "ap-south-1c"]
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gw" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "S3-node-app"
}

variable "project_env" {
  description = "Project Environment"
  type        = string
  default     = "Development"
}

variable "project_owner" {
  description = "Project Owner"
  type        = string
  default     = "Sreevas"
}

variable "app_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "sreevas-s3-node-app-2026"
}

variable "s3_code_bucket" {
  description = "S3 bucket for Code-deploy"
  type        = string
  default     = "sreevas-s3-node-app-code-2026"
}


variable "route53_hosted_zone_arn" {
  description = "route53_hosted_zone_arns"
  type        = string
  default     = "arn:aws:route53:::hostedzone/Z05823322O3AF5KJRMOWS"
}

variable "application_host" {
  description = "application_host"
  type        = string
  default     = "s3app.sreevasmk.online"
}

variable "domain_name" {
  description = "Route 53 zone"
  type        = string
  default     = "sreevasmk.online"
}

variable "acm_cert_host" {
  description = "ACM certificate host"
  type        = string
  default     = "*.sreevasmk.online"
}

variable "log_groups" {
  default = [
    "/s3-node-app/ec2",
    "/s3-node-app/application"
  ]
}

variable "github_username" {
  description = "Github username - application code"
  type        = string
  default     = "Sreevas-MK"
}
