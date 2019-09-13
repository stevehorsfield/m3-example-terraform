resource "aws_s3_bucket" "access-logs" {
  bucket = "${var.environment}-access-logs-${data.aws_region.this.name}"
  acl    = "private"

  tags {
    Name        = "${var.environment}-access-logs"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "access-logs" {
  bucket = "${aws_s3_bucket.access-logs.id}"
  policy = "${data.aws_iam_policy_document.access-logs-bucket.json}"
}

data "aws_elb_service_account" "this" {}

data "aws_iam_policy_document" "access-logs-bucket" {
  statement {
    sid = "AllowELBAccessLogging"
    effect = "Allow"
    resources = ["${aws_s3_bucket.access-logs.arn}/*"]
    actions = ["s3:PutObject"]
    principals {
      type = "AWS"
      identifiers = ["${data.aws_elb_service_account.this.arn}"]
    }
  }
}
