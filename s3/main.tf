resource "aws_iam_user" "s3" {
  name = "${var.service}_s3_${var.environment}"
  path = "/"  ###here and everywhere else use a variable to separate all these users we're making
}

resource "aws_iam_user_policy" "s3_policy" {
  name = "${var.service}_s3_policy_${var.environment}"
  user = "${aws_iam_user.s3.name}"
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

resource "aws_iam_access_key" "s3" {
  user = "${aws_iam_user.s3.name}"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.service}-${var.environment}-"
  acl    = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${var.log_bucket}"
    target_prefix = "log/"
  }
  tags = "${merge(map(
    "Name", "${var.tags["region"]}-${var.service}-${var.environment}",
    "Environment", "${var.environment}"),
    var.tags
  )}"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = "${aws_s3_bucket.this.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${var.service}",
  "Statement": [
    {
      "Sid": "Allow",
      "Effect": "Allow",
      "Principal": {"AWS": ["${aws_iam_user.s3.arn}"]},
      "Action": "*",
      "Resource": "${aws_s3_bucket.this.arn}"
    }
  ]
}
POLICY
}