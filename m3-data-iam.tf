resource "aws_iam_role" "m3-data" {

  name = "${var.environment}-m3-data"
  assume_role_policy = "${data.aws_iam_policy_document.m3-data-assume-role.json}"
}

data "aws_iam_policy_document" "m3-data-assume-role" {
  statement {
    sid     = "AllowEC2Assume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "m3-data" {
  name = "${var.environment}-m3-data"
  role = "${aws_iam_role.m3-data.id}"

}

resource "aws_iam_role_policy" "m3-data" {
  role   = "${aws_iam_role.m3-data.id}"
  policy = "${data.aws_iam_policy_document.m3-data.json}"
}

data "aws_iam_policy_document" "m3-data" {
  statement {
    sid = "AllowAccessToBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.distribution-artefacts.arn}",
      "${aws_s3_bucket.system-configuration.arn}",
    ]
  }

  statement {
    sid = "AllowAccessToDistributionArtefactsAndConfig"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.distribution-artefacts.arn}/*",
      "${aws_s3_bucket.system-configuration.arn}/m3/*",
      "${aws_s3_bucket.system-configuration.arn}/node-exporter/*",
      "${aws_s3_bucket.system-configuration.arn}/update-auto-reboot/*",
    ]
  }
}

