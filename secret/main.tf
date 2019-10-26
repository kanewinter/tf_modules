locals {
  service = "${var.tags["service"]}"
  region = "${var.tags["region"]}"
  environment = "${var.tags["environment"]}"
}

resource "aws_secretsmanager_secret" "password" {
  name = "${local.service}-${local.environment}"
  #name_prefix = "${local.service}-${local.environment}"
  tags = "${var.tags}"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = "${aws_secretsmanager_secret.password.id}"
  version_stages = ["AWSCURRENT"]
  secret_string = "${var.password}"
}

