data "template_file" "prometheus-config" {
  template = "${file("content/prometheus/configuration/prometheus.yml")}"

  vars = {
    kubernetes-dev-api-proxy-address = "${var.kubernetes-configuration["dev-api-proxy-address"]}"
    kubernetes-dev-api-endpoint-name = "${var.kubernetes-configuration["dev-tls-server-name"]}"
  }
}

resource "aws_s3_bucket_object" "prometheus-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "prometheus/configuration/prometheus.yml"
  content = "${data.template_file.prometheus-config.rendered}"
  acl     = "private"
  etag    = "${md5(data.template_file.prometheus-config.rendered)}"
}

resource "aws_s3_bucket_object" "prometheus-secrets-env" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/prometheus-secrets.env"
  source = "content/prometheus/configuration/prometheus-secrets.env"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/configuration/prometheus-secrets.env"))}"
}

resource "aws_s3_bucket_object" "prometheus-kubernetes-ca-dev" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/kubernetes-ca-dev.pem"
  source = "content/kubernetes/kubernetes-ca-dev.pem"
  acl    = "private"
  etag   = "${md5(file("content/kubernetes/kubernetes-ca-dev.pem"))}"
}

resource "aws_s3_bucket_object" "prometheus-kubernetes-ca-test" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/kubernetes-ca-test.pem"
  source = "content/kubernetes/kubernetes-ca-test.pem"
  acl    = "private"
  etag   = "${md5(file("content/kubernetes/kubernetes-ca-test.pem"))}"
}

resource "aws_s3_bucket_object" "prometheus-kubernetes-ca-production" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/kubernetes-ca-production.pem"
  source = "content/kubernetes/kubernetes-ca-production.pem"
  acl    = "private"
  etag   = "${md5(file("content/kubernetes/kubernetes-ca-production.pem"))}"
}

resource "aws_s3_bucket_object" "prometheus-config-transform" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/configuration/transform.jq"
  source = "content/prometheus/configuration/transform.jq"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/configuration/transform.jq"))}"
}

resource "aws_s3_bucket_object" "prometheus-install" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-install"
  source = "content/prometheus/install/prometheus-install"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-install"))}"
}

resource "aws_s3_bucket_object" "prometheus-service" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus.service"
  source = "content/prometheus/install/prometheus.service"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus.service"))}"
}

resource "aws_s3_bucket_object" "prometheus-configuration-sync" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-configuration-sync"
  source = "content/prometheus/install/prometheus-configuration-sync"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-configuration-sync"))}"
}

resource "aws_s3_bucket_object" "prometheus-decode-secrets" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/decode-secrets"
  source = "content/prometheus/install/decode-secrets"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/decode-secrets"))}"
}
resource "aws_s3_bucket_object" "prometheus-configuration-sync-service" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-configuration-sync.service"
  source = "content/prometheus/install/prometheus-configuration-sync.service"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-configuration-sync.service"))}"
}

resource "aws_s3_bucket_object" "prometheus-configuration-sync-timer" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-configuration-sync.timer"
  source = "content/prometheus/install/prometheus-configuration-sync.timer"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-configuration-sync.timer"))}"
}

resource "aws_s3_bucket_object" "prometheus-reload-path" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-reload.path"
  source = "content/prometheus/install/prometheus-reload.path"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-reload.path"))}"
}

resource "aws_s3_bucket_object" "prometheus-reload-service" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "prometheus/prometheus-reload.service"
  source = "content/prometheus/install/prometheus-reload.service"
  acl    = "private"
  etag   = "${md5(file("content/prometheus/install/prometheus-reload.service"))}"
}
