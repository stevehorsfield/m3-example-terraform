resource "aws_kms_grant" "prometheus-kubernetes-scrape-token-dev" {
  name   = "${var.environment}-prometheus-kubernetes-scrape-token-dev"
  key_id = "${aws_kms_key.secrets.id}"
  grantee_principal = "${aws_iam_role.prometheus.arn}"
  operations = ["Decrypt"]

  constraints {
    encryption_context_equals {
      Application = "prometheus"
      SecretName  = "prometheus-kubernetes-scrape-token-dev"
    }
  }
}