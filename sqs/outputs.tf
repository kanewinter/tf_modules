output "key" {
  sensitive = true
  value = "${aws_iam_access_key.sqs.id}"
}

output "secret" {
  sensitive = true
  value = "${aws_iam_access_key.sqs.secret}"
}

output "url" {
  value = "${module.sqs.this_sqs_queue_id}"
}

output "arn" {
  value = "${module.sqs.this_sqs_queue_arn}"
}