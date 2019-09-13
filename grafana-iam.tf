resource "aws_iam_role" "grafana" {

  name = "${var.environment}-grafana"
  assume_role_policy = "${data.aws_iam_policy_document.grafana-assume-role.json}"
}

data "aws_iam_policy_document" "grafana-assume-role" {
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

resource "aws_iam_instance_profile" "grafana" {
  name = "${var.environment}-grafana"
  role = "${aws_iam_role.grafana.id}"

}

resource "aws_iam_role_policy" "grafana" {
  role   = "${aws_iam_role.grafana.id}"
  policy = "${data.aws_iam_policy_document.grafana.json}"
}

data "aws_iam_policy_document" "grafana" {
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
      "${aws_s3_bucket.system-configuration.arn}/grafana/*",
      "${aws_s3_bucket.system-configuration.arn}/node-exporter/*",
    ]
  }
}