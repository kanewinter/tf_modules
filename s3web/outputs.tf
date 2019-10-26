output "key" {
  sensitive = true
  value = "${aws_iam_access_key.s3web.id}"
}

output "secret" {
  sensitive = true
  value = "${aws_iam_access_key.s3web.secret}"
}

output "region" {
  value = "${aws_s3_bucket.this.region}"
}

output "bucket" {
  value = "${aws_s3_bucket.this.bucket}"
}

output "arn" {
  value = "${aws_s3_bucket.this.arn}"
}

output "url" {
  value = "${aws_s3_bucket.this.bucket_domain_name}"
}

output "cdn" {
  value = "${aws_cloudfront_distribution.s3web.domain_name}"
}