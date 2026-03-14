output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.s3_app_alb.dns_name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "app_url" {
  description = "Application URL via Route53"
  value       = "https://${aws_route53_record.app.name}"
}
