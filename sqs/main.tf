resource "aws_iam_user" "sqs" {
  name = "${var.service}_sqs_${var.environment}"
  path = "/"
}

resource "aws_iam_user_policy" "sqs_policy" {
  name = "${var.service}_sqs_policy_${var.environment}"
  user = "${aws_iam_user.sqs.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
             ],
             "Resource": "${module.sqs.this_sqs_queue_arn}"
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "sqs" {
  user = "${aws_iam_user.sqs.name}"
}

module "sqs" {
  source = "terraform-aws-modules/sqs/aws"
  version = "1.0.0"
  name = "${var.service}_sqs_${var.environment}"
  fifo_queue = "${var.fifo_queue}"
  redrive_policy = "${var.redrive_policy}"
  visibility_timeout_seconds = "${var.visibility_timeout_seconds}"
  policy = <<EOF
  {
       "Version": "2012-10-17",
       "Statement": [{
          "Effect": "Allow",
          "Action": "*",
          "Resource": "${aws_iam_user.sqs.arn}"
       }]
  }
  EOF
  tags = "${merge(map(
    "Name", "${var.service}_${var.environment}",
    "resource", "sqs"),
    var.tags
  )}"
}