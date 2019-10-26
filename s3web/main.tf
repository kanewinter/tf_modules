resource "aws_iam_user" "s3web" {
  name = "${var.tags["service"]}_s3web_${var.tags["environment"]}"
  path = "/"  ###here and everywhere else use a variable to separate all these users we're making
}

resource "aws_iam_user_policy" "s3web_policy" {
  name = "${var.tags["service"]}_s3web_policy_${var.tags["environment"]}"
  user = "${aws_iam_user.s3web.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:*:*:job/*",
                "${aws_s3_bucket.this.arn}",
                "${aws_s3_bucket.this.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "s3web" {
  user = "${aws_iam_user.s3web.name}"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.tags["service"]}-web-${var.tags["environment"]}-"
  acl    = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${var.log_bucket}"
    target_prefix = "log/"
  }
  tags = "${merge(map(
    "Name", "${var.tags["region"]}-${var.tags["service"]}-${var.tags["environment"]}",
    "Environment", "${var.tags["environment"]}"),
    var.tags
  )}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

data "aws_iam_policy_document" "s3web_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.this.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
  statement {
    actions = ["*"]
    resources = ["${aws_s3_bucket.this.arn}"]
    principals {
      type = "AWS"
      identifiers = ["${aws_iam_user.s3web.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3web" {
  bucket = "${aws_s3_bucket.this.bucket}"
  policy = "${data.aws_iam_policy_document.s3web_policy.json}"
}

resource "aws_cloudfront_distribution" "s3web" {
  origin {
    domain_name = "${aws_s3_bucket.this.bucket_regional_domain_name}"
    origin_id   = "${var.tags["service"]}-${var.tags["environment"]}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class = "${var.priceclass}"

/*  logging_config {
    include_cookies = false
    bucket          = "${var.log_bucket}"
    prefix          = "${var.tags["service"]}-${var.tags["environment"]}-"
  }*/

  aliases = ["media-${var.tags["environment"]}.${var.tags["domain"]}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.tags["service"]}-${var.tags["environment"]}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
/*      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]*/
      restriction_type = "none"
    }
  }

  tags = "${var.tags}"

  viewer_certificate {
    acm_certificate_arn = "${var.cert}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}