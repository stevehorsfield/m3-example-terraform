data "template_file" "m3-etcd-clusterspec" {
  template = "$${hostname0}=https://$${hostip0}:2380,$${hostname1}=https://$${hostip1}:2380,$${hostname2}=https://$${hostip2}:2380"

  vars {
    hostip0 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
    hostip1 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,1), 32)}"
    hostip2 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,2), 32)}"
    hostname0 = "m3-etcd0.${replace(module.integration.dns-private-forward-zone-name, "/[.]$/", "")}"
    hostname1 = "m3-etcd1.${replace(module.integration.dns-private-forward-zone-name, "/[.]$/", "")}"
    hostname2 = "m3-etcd2.${replace(module.integration.dns-private-forward-zone-name, "/[.]$/", "")}"
  }
}

resource "random_string" "m3-etcd-cluster-token" {
  length  = 32
  special = false
  keepers = {
    version = 1
  }
}

resource "aws_s3_bucket_object" "m3-etcd-unit-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/etcd/m3-etcd.service"
  source = "content/m3/etcd/m3-etcd.service"
  acl    = "private"
  etag   = "${md5(file("content/m3/etcd/m3-etcd.service"))}"
}

resource "aws_s3_bucket_object" "m3-etcd-snapshot-unit-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/etcd/m3-etcd-snapshot.service"
  source = "content/m3/etcd/m3-etcd-snapshot.service"
  acl    = "private"
  etag   = "${md5(file("content/m3/etcd/m3-etcd-snapshot.service"))}"
}

resource "aws_s3_bucket_object" "m3-etcd-snapshot-timer-unit-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/etcd/m3-etcd-snapshot.timer"
  source = "content/m3/etcd/m3-etcd-snapshot.timer"
  acl    = "private"
  etag   = "${md5(file("content/m3/etcd/m3-etcd-snapshot.timer"))}"
}