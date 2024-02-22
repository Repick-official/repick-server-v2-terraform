resource "aws_route53_zone" "repick_zone" {
  name = var.route53_zone_domain

  tags = {
    Name = "repick-zone"
  }
}

resource "aws_acm_certificate" "repick_certificate" {
  domain_name       = "*.${var.route53_zone_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "repick-certificate"
  }
}

resource "aws_route53_record" "repick_certificate_dns" {
  name    = tolist(aws_acm_certificate.repick_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.repick_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.repick_zone.zone_id
  records = [tolist(aws_acm_certificate.repick_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "repick_certificate_validation" {
  certificate_arn         = aws_acm_certificate.repick_certificate.arn
  validation_record_fqdns = [aws_route53_record.repick_certificate_dns.fqdn]
}

resource "aws_route53_record" "www" {
  name    = "www.${aws_route53_zone.repick_zone.name}"
  type    = "A"
  zone_id = aws_route53_zone.repick_zone.zone_id

  alias {
    name                   = aws_lb.repick.dns_name
    zone_id                = aws_lb.repick.zone_id
    evaluate_target_health = false
  }
}


output "name_servers" {
  description = "The name servers of the hosted zone"
  value       = aws_route53_zone.repick_zone.name_servers
}