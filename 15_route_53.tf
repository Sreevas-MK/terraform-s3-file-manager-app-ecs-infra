resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = var.application_host
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
