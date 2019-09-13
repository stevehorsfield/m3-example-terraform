data "template_file" "m3-coordinator-config" {
  template = "${file("content/m3/coordinator/coordinator-config.yml")}"

  vars {
    etcd-hostip0 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
    etcd-hostip1 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,1), 32)}"
    etcd-hostip2 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,2), 32)}"
  }
}

resource "aws_s3_bucket_object" "m3-coordinator-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "m3/query/config.yml"
  content = "${data.template_file.m3-query-config.rendered}"
  acl     = "private"
}

resource "aws_s3_bucket_object" "m3-coordinator-install-script" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/m3/coordinator-install"
  source = "content/m3/coordinator/coordinator-install"
  acl    = "private"
  etag   = "${md5(file("content/m3/coordinator/coordinator-install"))}"
}

resource "aws_s3_bucket_object" "m3-coordinator-config-file" {
  bucket  = "${aws_s3_bucket.system-configuration.bucket}"
  key     = "/m3/coordinator-config.yml"
  content = "${data.template_file.m3-coordinator-config.rendered}"
  acl     = "private"
  etag   = "${md5(data.template_file.m3-coordinator-config.rendered)}"
}

resource "aws_s3_bucket_object" "m3-coordinator-service-file" {
  bucket = "${aws_s3_bucket.system-configuration.bucket}"
  key    = "/m3/m3-coordinator.service"
  source = "content/m3/coordinator/m3-coordinator.service"
  acl    = "private"
  etag   = "${md5(file("content/m3/coordinator/m3-coordinator.service"))}"
}