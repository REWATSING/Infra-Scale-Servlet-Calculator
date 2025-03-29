data "aws_route53_zone" "rewat_com" {
  name         = "rewat.com"
  private_zone = false
}

resource "aws_route53_record" "elb_dns" {
  zone_id = data.aws_route53_zone.rewat_com.zone_id
  name    = "rewat.com"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}




resource "tls_private_key" "ssl_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ssl_cert" {
  private_key_pem = tls_private_key.ssl_key.private_key_pem

  subject {
    common_name  = "www.rewat.com"
    organization = "Q3Tech"
  }

  validity_period_hours = 8760
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "imported_cert" {
  private_key      = tls_private_key.ssl_key.private_key_pem
  certificate_body = tls_self_signed_cert.ssl_cert.cert_pem

  tags = {
    Name = "SelfSignedCert-www.rewat.com"
  }
}