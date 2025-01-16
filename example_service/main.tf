provider aws {
  alias = "us_east_1"
  region = "us-east-1"
  profile = var.profile
}

provider aws {
  region = var.region
  profile = var.profile
}

#--------------------------------------------------------------
# s3
resource "aws_s3_bucket" "example_service" {
  bucket = var.bucket_name
  tags = {
    id_env = var.id_env
    id_cat = var.id_cat
    id_group = var.id_group
    id_service = var.id_service
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example_service" {
  bucket = aws_s3_bucket.example_service.bucket
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "example_service" {
  bucket = aws_s3_bucket.example_service.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.example_service.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "example_service" {
  bucket = aws_s3_bucket.example_service.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example_service" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example_service,
    aws_s3_bucket_public_access_block.example_service,
  ]

  bucket = aws_s3_bucket.example_service.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "example_service" {
  bucket = aws_s3_bucket.example_service.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
  }

}

resource "null_resource" "upload_src" {
  provisioner "local-exec" {
    command = "aws s3 cp --recursive ${path.module}/src s3://${aws_s3_bucket.example_service.bucket}/"
  }
}

resource "aws_s3_bucket_website_configuration" "example_service" {
  bucket = aws_s3_bucket.example_service.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

#--------------------------------------------------------------
# acm

resource "aws_acm_certificate" "cert" {
  # cloudfront에서 사용할 인증서의 경우 region이 us-east-1이어야 한다.
  provider = aws.us_east_1
  domain_name       = "${var.subdomain_name}.${data.aws_route53_zone.selected.name}"
  validation_method = "DNS"

  tags = {
    id_env = var.id_env
    id_cat = var.id_cat
    id_group = var.id_group
    id_service = var.id_service
  }
}


resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

}

#--------------------------------------------------------------
# cloudfront

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "CloudFront OAI for static site"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name = "example-service-oac"
  description = "Origin Access Control for example service"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}


resource "aws_cloudfront_distribution" "example_service_cf" {
  provider = aws.us_east_1
  origin {
    domain_name = aws_s3_bucket.example_service.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id   = "S3-${aws_s3_bucket.example_service.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "example service distribution test"
  default_root_object = "index.html"
  aliases             = ["${var.subdomain_name}.${data.aws_route53_zone.selected.name}"]
  
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.example_service.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }    
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  tags = {
    id_env = var.id_env
    id_cat = var.id_cat
    id_group = var.id_group
    id_service = var.id_service
  }
}

#--------------------------------------------------------------
# route53

data "aws_route53_zone" "selected" {
  name = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "example_service_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain_name}.${data.aws_route53_zone.selected.name}"
  type    = var.record_type
  alias {
    name                   = aws_cloudfront_distribution.example_service_cf.domain_name
    zone_id                = aws_cloudfront_distribution.example_service_cf.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}