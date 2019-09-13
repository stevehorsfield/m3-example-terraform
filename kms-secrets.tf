resource "aws_kms_key" "secrets" {
  description  = "${var.environment} - key for encoding secrets"
  deletion_window_in_days = 30
  policy = ""
  is_enabled = true
  enable_key_rotation = true

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-secrets"
  }
}

data "aws_iam_policy_document" "secrets-key" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }
}

resource "aws_kms_alias" "secrets" {
  target_key_id = "${aws_kms_key.secrets.id}"
  name = "alias/${var.environment}-secrets"
}