resource "aws_route53_zone" "metabase" {
  name = var.dns_zone_name
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = var.dns_zone_name
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_acm_certificate" "metabase" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = format("%s-metabase", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_route53_record" "certificate" {
  zone_id = aws_route53_zone.metabase.zone_id
  name    = one(aws_acm_certificate.metabase.domain_validation_options).resource_record_name
  type    = one(aws_acm_certificate.metabase.domain_validation_options).resource_record_type
  ttl     = 60
  records = [one(aws_acm_certificate.metabase.domain_validation_options).resource_record_value]
}

resource "aws_acm_certificate_validation" "metabase" {
  certificate_arn         = aws_acm_certificate.metabase.arn
  validation_record_fqdns = [aws_route53_record.certificate.fqdn]
}

resource "aws_route53_record" "metabase" {
  zone_id = aws_route53_zone.metabase.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.metabase.dns_name
    zone_id                = aws_lb.metabase.zone_id
    evaluate_target_health = true
  }
}
