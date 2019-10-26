locals {
  service = "demo"
  tags= "${merge(map(
    "service", "${local.service}"),
    var.environment_tags
  )}"
  rds_subnet_group_id = "${data.terraform_remote_state.environment_state.default_db_subnet_group_id}"
  rds_parameter_group = "${data.terraform_remote_state.environment_state.default_mysql_parameter_group_id}"
  rds_option_group_id = "${data.terraform_remote_state.environment_state.default_mysql_option_group_id}"
  ec_parameter_group = "${data.terraform_remote_state.environment_state.default_elasticache_redis_parameter_group_name}"
  ec_subnet_group_id = "${data.terraform_remote_state.environment_state.default_elasticache_subnet_group_id}"
  mem_parameter_group = "${data.terraform_remote_state.environment_state.default_elasticache_memcache_parameter_group_name}"
  default_sg_id = ["${data.terraform_remote_state.environment_state.default_sg_id}"]
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "environment_state" {
  backend = "s3"
  config {
    bucket = "terraform-state"
    key = "${local.tags["environment"]}/terraform.tfstate"
    region = "us-west-2"
  }
}

module "secrets" {
  source = "github.com/kanewinter/tf_modules//secret?ref=master"
  tags = ["${local.tags}"]
  password = <<PWSTRING
K8S_SECRET_DB_HOST=${module.rds.endpoint}
K8S_SECRET_DB_USERNAME=${module.rds.username}
K8S_SECRET_DB_PASSWORD=${data.aws_secretsmanager_secret_version.rds.secret_string}
K8S_SECRET_DB_DATABASE=${module.rds.name}
K8S_SECRET_SQS_URL=${module.sqs.url}
K8S_SECRET_SQS_KEY=${module.sqs.key}
K8S_SECRET_SQS_SECRET=${module.sqs.secret}
K8S_SECRET_SQS_REGION=${local.tags["region"]}
K8S_SECRET_S3_KEY=${module.s3.key}
K8S_SECRET_S3_SECRET=${module.s3.secret}
K8S_SECRET_S3_REGION=${module.s3.region}
K8S_SECRET_S3_BUCKET=${module.s3.bucket}
K8S_SECRET_S3_URL=${module.s3.url}
K8S_SECRET_S3WEB_KEY=${module.s3web.key}
K8S_SECRET_S3WEB_SECRET=${module.s3web.secret}
K8S_SECRET_S3WEB_REGION=${module.s3web.region}
K8S_SECRET_S3WEB_BUCKET=${module.s3web.bucket}
K8S_SECRET_S3WEB_URL=${module.s3web.url}
K8S_SECRET_EC_HOST=${module.elasticache.address}
K8S_SECRET_MEMCACHED_HOST=${module.memcached.address}
K8S_SECRET_ES_HOST=${module.es.endpoint}:443
K8S_SECRET_SES_KEY=${module.ses.key}
K8S_SECRET_SES_SECRET=${module.ses.secret}
K8S_SECRET_SES_DOMAIN=mail-${local.tags["environment"]}.${local.tags["domain"]}
PWSTRING
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = "${local.tags["service"]}-rds-${local.tags["environment"]}"
}

module "rds" {
  source = "github.com/kanewinter/tf_modules//rds?ref=master"
  application = "${local.tags["service"]}"
  environment = "${local.tags["environment"]}"
  rds_password = "${data.aws_secretsmanager_secret_version.rds.secret_string}"
  vpc_security_group_ids = ["${local.default_sg_id}"]
  subnet_group_id = "${local.rds_subnet_group_id}"
  parameter_group_id = "${local.rds_parameter_group}"
  option_group_id = "${local.rds_option_group_id}"
  tags = ["${local.tags}"]
}

module "sqs" {
  source = "github.com/kanewinter/tf_modules//sqs?ref=master"
  service = "${local.tags["service"]}"
  environment = "${local.tags["region"]}-${local.tags["environment"]}"
  tags = ["${local.tags}"]
}

module "s3" {
  source = "github.com/kanewinter/tf_modules//s3?ref=master"
  service = "${local.tags["service"]}"
  environment = "${local.tags["environment"]}"
  log_bucket = "${data.terraform_remote_state.environment_state.s3_log_bucket_id}"
  tags = ["${local.tags}"]
}

module "s3web" {
  source = "github.com/kanewinter/tf_modules//s3web?ref=master"
  cert = "${var.cert}"
  log_bucket = "${data.terraform_remote_state.environment_state.s3_log_bucket_id}"
  tags = ["${local.tags}"]
}

resource "aws_route53_record" "cdn" {
  zone_id = "${var.zone_id}"
  name    = "media.${local.tags["service"]}-${local.tags["environment"]}.${local.tags["domain"]}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${module.s3web.cdn}"]
}

module "elasticache" {
  source = "github.com/kanewinter/tf_modules//elasticache?ref=master"
  region = "${local.tags["region"]}"
  azs = ["${local.tags["azs"]}"]
  environment = "${local.tags["environment"]}"
  parameter_group_name = "${local.ec_parameter_group}"
  subnet_group = "${local.ec_subnet_group_id}"
  security_group_ids = ["${data.terraform_remote_state.environment_state.default_elasticache_sg_id}"]
  tags = ["${local.tags}"]
}

module "memcached" {
  source = "github.com/kanewinter/tf_modules//memcached?ref=master"
  parameter_group_name = "${local.mem_parameter_group}"
  azs = ["${local.tags["azs"]}"]
  tags = ["${local.tags}"]
}

module "es" {
  source = "github.com/kanewinter/tf_modules//elasticsearch?ref=master"
  security_group_id = "${data.terraform_remote_state.environment_state.default_sg_id}"
  subnet_ids = "${data.terraform_remote_state.environment_state.subnet_ids}"
  cloudwatch_log_group = "${data.terraform_remote_state.environment_state.elasticsearch_cloudwatch_log_arn}"
  tags = ["${local.tags}"]
}

module "ses" {
  source = "github.com/kanewinter/tf_modules//ses?ref=master"
  domain = "mail-${local.tags["environment"]}.${local.tags["domain"]}"
  zone_id = "${var.zone_id}"
  tags = ["${local.tags}"]
}