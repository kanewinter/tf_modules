output "key" {
  sensitive = true
  value = "${aws_iam_access_key.s3.id}"
}

output "secret" {
  sensitive = true
  value = "${aws_iam_access_key.s3.secret}"
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