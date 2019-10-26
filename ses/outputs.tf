output "secret" {
  description = "The secret access key converted into an SES SMTP password"
  value = "${aws_iam_access_key.ses.secret}"
}

output "key" {
  sensitive = true
  value = "${aws_iam_access_key.ses.id}"
}

output "smtp_password" {
  description = "The secret access key converted into an SES SMTP password"
  value = "${aws_iam_access_key.ses.ses_smtp_password}"
}

