resource "aws_iam_role" "m3-etcd" {

  name = "${var.environment}-m3-etcd"
  assume_role_policy = "${data.aws_iam_policy_document.m3-etcd-assume-role.json}"
}

data "aws_iam_policy_document" "m3-etcd-assume-role" {
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

resource "aws_iam_instance_profile" "m3-etcd" {
  name = "${var.environment}-m3-etcd"
  role = "${aws_iam_role.m3-etcd.id}"

}

resource "aws_iam_role_policy" "m3-etcd" {
  role   = "${aws_iam_role.m3-etcd.id}"
  policy = "${data.aws_iam_policy_document.m3-etcd.json}"
}

data "aws_iam_policy_document" "m3-etcd" {
  statement {
    sid = "AllowAccessToDistributionArtefactsBucket"
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
    sid = "AllowAccessToDistributionArtefacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.distribution-artefacts.arn}/*",
      "${aws_s3_bucket.system-configuration.arn}/m3/etcd/*",
      "${aws_s3_bucket.system-configuration.arn}/node-exporter/*",
      "${aws_s3_bucket.system-configuration.arn}/update-auto-reboot/*",
    ]
  }
}

