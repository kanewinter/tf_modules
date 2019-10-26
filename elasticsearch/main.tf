locals {
  tags = "${merge(map(
    "Name", "${var.tags["service"]}-es-${var.tags["environment"]}"),
    var.tags
  )}"
  service = "${var.tags["service"]}"
  region = "${var.tags["region"]}"
  name = "${var.tags["service"]}-es-${var.tags["environment"]}"
  environment = "${var.tags["environment"]}"
}

resource "aws_elasticsearch_domain_policy" "this" {
  domain_name = "${aws_elasticsearch_domain.this.domain_name}"

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "${aws_elasticsearch_domain.this.arn}/*"
    }
  ]
}
POLICIES
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${local.name}"
  elasticsearch_version = "6.4"
  cluster_config {
    #####Possible Instance types:
    #[i3.2xlarge.elasticsearch, i3.4xlarge.elasticsearch, m3.large.elasticsearch, r4.16xlarge.elasticsearch, t2.micro.elasticsearch, m4.large.elasticsearch, d2.2xlarge.elasticsearch, i3.8xlarge.elasticsearch, i3.large.elasticsearch, d2.4xlarge.elasticsearch, t2.small.elasticsearch, c4.2xlarge.elasticsearch, c4.4xlarge.elasticsearch, d2.8xlarge.elasticsearch, m3.medium.elasticsearch, c4.8xlarge.elasticsearch, c4.large.elasticsearch, c4.xlarge.elasticsearch, d2.xlarge.elasticsearch, t2.medium.elasticsearch, i3.xlarge.elasticsearch, i2.xlarge.elasticsearch, r3.2xlarge.elasticsearch, r4.2xlarge.elasticsearch, m4.10xlarge.elasticsearch, r3.4xlarge.elasticsearch, m4.xlarge.elasticsearch, r4.4xlarge.elasticsearch, m3.xlarge.elasticsearch, i3.16xlarge.elasticsearch, m3.2xlarge.elasticsearch, r3.8xlarge.elasticsearch, r3.large.elasticsearch, m4.2xlarge.elasticsearch, r4.8xlarge.elasticsearch, r4.xlarge.elasticsearch, r4.large.elasticsearch, i2.2xlarge.elasticsearch, r3.xlarge.elasticsearch, m4.4xlarge.elasticsearch]
    instance_type = "${var.instance_type}"
    instance_count = "2"
    zone_awareness_enabled = true
  }

  vpc_options {
    security_group_ids = ["${var.security_group_id}"]
    subnet_ids = ["${var.subnet_ids[0]}", "${var.subnet_ids[1]}"]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "20"
  }

  snapshot_options {
    automated_snapshot_start_hour = 1
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${var.cloudwatch_log_group}"
    log_type                 = "INDEX_SLOW_LOGS"
  }

  tags = "${local.tags}"
}