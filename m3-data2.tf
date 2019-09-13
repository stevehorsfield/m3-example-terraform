resource "aws_instance" "m3-data2" {
  ami                         = "${var.m3-configuration["data2-ami"]}"
  subnet_id                   = "${element(module.integration.private_subnets,2)}"  # implies AZ
  associate_public_ip_address = false
  source_dest_check           = true
  placement_group             = ""
  ebs_optimized               = true
  disable_api_termination     = false
  instance_type               = "${var.m3-configuration["data2-instance-type"]}"
  key_name                    = "${var.m3-configuration["data2-ec2-key-name"]}"
  monitoring                  = false                                               # detailed monitoring
  iam_instance_profile        = "${aws_iam_instance_profile.m3-data.name}"
  user_data                   = "${data.template_file.m3-data2-userdata.rendered}"

  vpc_security_group_ids = ["${aws_security_group.m3-data.id}"]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "${var.m3-configuration["data2-root-volume-gb"]}"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.environment}-m3-data2"
    Environment = "${var.environment}"
    Application = "M3"
    VpcHostname = "m3-data2"

    "prometheus.scraping.m3.port"            = "9004"
    "prometheus.scraping.node-exporter.port" = 9100
  }
}

data "template_file" "m3-data2-config" {
  template = "${file("content/m3/data2/config.yml")}"

  vars {
    etcd-hostip0 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
    etcd-hostip1 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,1), 32)}"
    etcd-hostip2 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,2), 32)}"
  }
}

data "template_file" "m3-data2-coordinator-config" {
  template = "${file("content/m3/data2/coordinator-config.yml")}"

  vars {
    etcd-hostip0 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
    etcd-hostip1 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,1), 32)}"
    etcd-hostip2 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,2), 32)}"
  }
}

resource "aws_s3_bucket_object" "m3-data2-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "m3/data2/config.yml"
  content = "${data.template_file.m3-data2-config.rendered}"
  acl     = "private"
  etag    = "${md5(data.template_file.m3-data2-config.rendered)}"
}

resource "aws_s3_bucket_object" "m3-data2-coordinator-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "m3/data2/coordinator-config.yml"
  content = "${data.template_file.m3-data2-coordinator-config.rendered}"
  acl     = "private"
  etag    = "${md5(data.template_file.m3-data2-coordinator-config.rendered)}"
}

resource "aws_s3_bucket_object" "m3-data2-service-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/data2/m3-data.service"
  source = "content/m3/data2/m3-data.service"
  acl    = "private"
  etag   = "${md5(file("content/m3/data2/m3-data.service"))}"
}

resource "aws_s3_bucket_object" "m3-data2-coordinator-service-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/data2/m3-coordinator.service"
  source = "content/m3/data2/m3-coordinator.service"
  acl    = "private"
  etag   = "${md5(file("content/m3/data2/m3-coordinator.service"))}"
}

resource "aws_s3_bucket_object" "m3-data2-install-file" {
  bucket = "${aws_s3_bucket.system-configuration.id}"
  key    = "m3/data2/install"
  source = "content/m3/data2/install"
  acl    = "private"
  etag   = "${md5(file("content/m3/data2/install"))}"
}

data "template_file" "m3-data2-userdata" {
  template = "${file("content/m3/data2/cloudinit.yml")}"

  vars {
    hostname-manager-unit-file           = "${base64encode(file("content/hostname-manager/hostname-manager.service"))}"
    hostname-manager-apply-hostname-file = "${base64encode(file("content/hostname-manager/apply-hostname"))}"

    filesystems-check-and-mount-file = "${base64encode(file("content/filesystems/check-and-mount"))}"
    filesystems-format-if-empty-file = "${base64encode(file("content/filesystems/format-if-empty"))}"

    launch-script = "${base64encode(file("content/m3/data2/launch"))}"
    hostname      = "m3-data2.${module.integration.dns-private-forward-zone-name}"

    etcd-release-s3-uri = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["data2-etcd-binary-key"]}"
    m3-release-s3-uri   = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["data2-m3-binary-key"]}"

    m3-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/m3/data2"

    node-exporter-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.m3-configuration["data2-node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    update-auto-reboot-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/update-auto-reboot"

    # Force change tracking
    m3-data-config-s3-version                   = "${aws_s3_bucket_object.m3-data2-config.version_id}"
    m3-data-coordinator-config-s3-version       = "${aws_s3_bucket_object.m3-data2-coordinator-config.version_id}"
    m3-data-coordinator-service-file-s3-version = "${aws_s3_bucket_object.m3-data2-coordinator-service-file.version_id}"
    m3-data-service-file-s3-version             = "${aws_s3_bucket_object.m3-data2-service-file.version_id}"
    m3-data-install-file-s3-version             = "${aws_s3_bucket_object.m3-data2-install-file.version_id}"
  }
}

resource "aws_ebs_volume" "m3-data2-data" {
  availability_zone = "${data.aws_region.this.name}${element(module.integration.azs,2)}"
  encrypted         = true
  size              = "${var.m3-configuration["data-data-volume-gb"]}"
  type              = "gp2"
  
  tags = {
    Name        = "${var.environment}-m3-data2-data"
    Environment = "${var.environment}"
    Application = "M3"
    Volume      = "data2-data"
  }
}

resource "aws_volume_attachment" "m3-data2-data" {
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.m3-data2-data.id}"
  instance_id = "${aws_instance.m3-data2.id}"

  skip_destroy = true
}

resource "aws_cloudwatch_metric_alarm" "m3-data2-recovery" {
  alarm_name          = "${var.environment}-m3-data2-auto-recover"
  namespace           = "AWS/EC2"
  evaluation_periods  = "2"
  period              = "60"
  alarm_description   = ""
  alarm_actions       = ["arn:aws:automate:${data.aws_region.this.name}:ec2:recover"]
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  metric_name         = "StatusCheckFailed_System"

  dimensions {
    InstanceId = "${aws_instance.m3-data2.id}"
  }
}
