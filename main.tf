provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

locals {
  default_certs = var.use_default_domain ? ["default"] : []
  acm_certs     = var.use_default_domain ? [] : ["acm"]
  domain_name   = var.use_default_domain ? [] : [var.domain_name]
}

data "aws_acm_certificate" "acm_cert" {
  count    = var.use_default_domain ? 0 : 1
  domain   = coalesce(var.acm_certificate_domain, "*.${var.hosted_zone}")
  provider = aws.aws_cloudfront
  //CloudFront uses certificates from US-EAST-1 region only
  statuses = [
    "ISSUED",
  ]
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_bucket_policy.json

  versioning {
    enabled = true
  }
  
  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  website {
    index_document = var.website_index
    error_document = var.website_error
  }

  tags = var.tags
}

resource "aws_s3_bucket_object" "object" {
  count        = var.upload_sample_file ? 1 : 0
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

data "aws_route53_zone" "domain_name" {
  count        = var.use_default_domain ? 0 : 1
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "route53_record" {
  count = var.use_default_domain ? 0 : 1
  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]

  zone_id = data.aws_route53_zone.domain_name[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = "Z2FDTNDATAQYW2"

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_s3_bucket.s3_bucket
  ]

  origin {
    domain_name = aws_s3_bucket.s3_bucket.website_endpoint
    origin_id   = "S3-Website-${aws_s3_bucket.s3_bucket.website_endpoint}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  dynamic "origin" {
    for_each = var.extra_origin
    iterator = i

    content {
      domain_name         = i.value.domain_name
      origin_id           = lookup(i.value, "origin_id", i.key)
      origin_path         = lookup(i.value, "origin_path", "")

      dynamic "s3_origin_config" {
        for_each = length(keys(lookup(i.value, "s3_origin_config", {}))) == 0 ? [] : [lookup(i.value, "s3_origin_config", {})]

        content {
          origin_access_identity = lookup(s3_origin_config.value, "cloudfront_access_identity_path", lookup(lookup(aws_cloudfront_origin_access_identity.this, lookup(s3_origin_config.value, "origin_access_identity", ""), {}), "cloudfront_access_identity_path", null))
        }
      }

      dynamic "custom_origin_config" {
        for_each = length(lookup(i.value, "custom_origin_config", "")) == 0 ? [] : [lookup(i.value, "custom_origin_config", "")]

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(i.value, "custom_header", [])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    iterator = i

    content {
      path_pattern           = i.value["path_pattern"]
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

        content {
          query_string            = lookup(i.value, "query_string", false)
          query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
          headers                 = lookup(i.value, "headers", [])

          cookies {
            forward           = lookup(i.value, "cookies_forward", "none")
            whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.domain_name

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "S3-Website-${aws_s3_bucket.s3_bucket.website_endpoint}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  dynamic "viewer_certificate" {
    for_each = local.default_certs
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.acm_certs
    content {
      acm_certificate_arn      = data.aws_acm_certificate.acm_cert[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
  }

  wait_for_deployment = false
  tags                = var.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}
