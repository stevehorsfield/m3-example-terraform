output "distribution-artefacts" {
  value = {
    bucket = "${aws_s3_bucket.distribution-artefacts.id}"
    arn    = "${aws_s3_bucket.distribution-artefacts.arn}"
  }
}

output "prometheus-scraping-security-group" {
  value = "${data.aws_caller_identity.this.account_id}/${aws_security_group.prometheus.id}"
}