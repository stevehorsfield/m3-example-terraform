resource "aws_s3_bucket_object" "prometheus-config-rules-k8s" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/rules-k8s.yml"
  source = "content/prometheus/configuration/rules-k8s.yml"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/configuration/rules-k8s.yml"))}"
}

resource "aws_s3_bucket_object" "prometheus-config-rules-linux-node" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/rules-linux-node.yml"
  source = "content/prometheus/configuration/rules-linux-node.yml"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/configuration/rules-linux-node.yml"))}"
}