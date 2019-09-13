resource "aws_iam_role" "prometheus" {

  name = "${var.environment}-prometheus"
  assume_role_policy = "${data.aws_iam_policy_document.prometheus-assume-role.json}"
}

data "aws_iam_policy_document" "prometheus-assume-role" {
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

resource "aws_iam_instance_profile" "prometheus" {
  name = "${var.environment}-prometheus"
  role = "${aws_iam_role.prometheus.id}"

}

resource "aws_iam_role_policy" "prometheus" {
  role   = "${aws_iam_role.prometheus.id}"
  policy = "${data.aws_iam_policy_document.prometheus.json}"
}

data "aws_iam_policy_document" "prometheus" {
  statement {
    sid = "AllowAttachDetachVolumes"
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = [
      "${aws_ebs_volume.prometheus0.arn}",
      "${aws_ebs_volume.prometheus1.arn}",
      "${aws_ebs_volume.prometheus2.arn}",
      "arn:aws:ec2:*:*:instance/*",
    ]
  }

  statement {
    sid = "AllowDescribeVolume"
    effect = "Allow"
    actions = ["ec2:DescribeVolumes"]
    resources = ["*"]
  }

  statement {
    sid = "AllowDownloadArtefacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${aws_s3_bucket.distribution-artefacts.arn}/*",
      "${aws_s3_bucket.system-configuration.arn}/prometheus/*",
      "${aws_s3_bucket.system-configuration.arn}/node-exporter/*",
      "${aws_s3_bucket.system-configuration.arn}/m3/*",
    ]
  }

  statement {
    sid = "AllowListArtefactsBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.distribution-artefacts.arn}",
      "${aws_s3_bucket.system-configuration.arn}"
    ]
  }

  statement {
    sid = "AllowEC2DiscoveryForScraping"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowAssumeRoleOtherAccounts"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "${var.prometheus-configuration["production-discovery-role"]}",
    ]
  }
}

