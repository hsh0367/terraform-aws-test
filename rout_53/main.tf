provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_route53_zone" "selected" {
  name = var.hosted_zone_name
  private_zone = false
}


resource "aws_route53_record" "new_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain_name}.${data.aws_route53_zone.selected.name}"
  # type 종류: A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV, TXT
  type    = var.record_type
  ttl     = var.ttl
  records = [var.record_value]
}