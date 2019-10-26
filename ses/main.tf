locals {
  tags = "${var.tags}"
  service = "${var.tags["service"]}"
  region = "${var.tags["region"]}"
  environment = "${var.tags["environment"]}"
  # some ses resources don't allow for the terminating '.' in the domain name
  # so use a replace function to strip it out
  stripped_domain_name = "${replace(var.domain, "/[.]$/", "")}"
  stripped_mail_from_domain = "${var.sender}.${replace(var.domain, "/[.]$/", "")}"
  dash_domain               = "${replace(var.domain, ".", "-")}"
}

resource "aws_iam_user" "ses" {
  name = "${local.service}_ses_${local.environment}"
  path = "/${local.service}/"
}

resource "aws_iam_user_policy" "ses_policy" {
  name = "${local.service}_ses_policy_${local.environment}"
  user = "${aws_iam_user.ses.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
             ],
             "Resource": "${aws_ses_domain_identity.domain.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "ses" {
  user = "${aws_iam_user.ses.name}"
}

resource "aws_ses_domain_identity" "domain" {
  domain = "${var.domain}"
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = "${aws_ses_domain_identity.domain.domain}"
  mail_from_domain = "${local.stripped_mail_from_domain}"
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = "${aws_ses_domain_identity.domain.domain}"
}

resource "aws_route53_record" "domain_amazonses_verification_record" {
  zone_id = "${var.zone_id}"
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "3600"
  records = ["${aws_ses_domain_identity.domain.verification_token}", "${var.ses_records}"]
}

resource "aws_route53_record" "domain_amazonses_dkim_record" {
  count   = 3
  zone_id = "${var.zone_id}"
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SPF validaton record
resource "aws_route53_record" "spf_mail_from" {
  zone_id = "${var.zone_id}"
  name    = "${aws_ses_domain_mail_from.main.mail_from_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "spf_domain" {
  zone_id = "${var.zone_id}"
  name    = "${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

# Sending MX Record
resource "aws_route53_record" "mx_send_mail_from" {
  zone_id = "${var.zone_id}"
  name    = "${aws_ses_domain_mail_from.main.mail_from_domain}"
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${local.region}-${local.environment}.amazonses.com"]
}

# Receiving MX Record
resource "aws_route53_record" "mx_receive" {
  zone_id = "${var.zone_id}"
  name    = "${var.domain}"
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${local.region}-${local.environment}.amazonaws.com"]
}