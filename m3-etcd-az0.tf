resource "aws_instance" "m3-etcd0" {
  ami                         = "${var.m3-configuration["etcd-ami"]}"
  private_ip                  = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
  subnet_id                   = "${element(module.integration.private_fixed_subnets,0)}"  # implies AZ
  associate_public_ip_address = false
  source_dest_check           = true
  placement_group             = ""
  ebs_optimized               = true
  disable_api_termination     = false
  instance_type               = "${var.m3-configuration["etcd-instance-type"]}"
  key_name                    = "${var.m3-configuration["etcd-ec2-key-name"]}"
  monitoring                  = false                                               # detailed monitoring
  iam_instance_profile        = "${aws_iam_instance_profile.m3-etcd.name}"
  user_data                   = "${data.template_file.m3-etcd0-userdata.rendered}"

  vpc_security_group_ids = ["${aws_security_group.m3-etcd.id}"]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "${var.m3-configuration["etcd-root-volume-gb"]}"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.environment}-m3-etcd0"
    Environment = "${var.environment}"
    Application = "M3"
    VpcHostname = "m3-etcd0"

    prometheus.scraping.etcd.port          = 2379
    prometheus.scraping.node-exporter.port = 9100
  }
}

data "template_file" "m3-etcd0-userdata" {
  template = "${file("content/m3/etcd/cloudinit.yml")}"

  vars {
    hostname-manager-unit-file           = "${base64encode(file("content/hostname-manager/hostname-manager.service"))}"
    hostname-manager-apply-hostname-file = "${base64encode(file("content/hostname-manager/apply-hostname"))}"

    filesystems-check-and-mount-file = "${base64encode(file("content/filesystems/check-and-mount"))}"
    filesystems-format-if-empty-file = "${base64encode(file("content/filesystems/format-if-empty"))}"

    node-exporter-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.m3-configuration["etcd-node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    update-auto-reboot-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/update-auto-reboot"

    launch-script = "${base64encode(file("content/m3/etcd/launch"))}"
    hostname      = "m3-etcd0.${module.integration.dns-private-forward-zone-name}"

    etcd-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["etcd-binary-key"]}"
    etcd-cluster-spec              = "${data.template_file.m3-etcd-clusterspec.rendered}"
    etcd-cluster-token             = "${random_string.m3-etcd-cluster-token.result}"
    etcd-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/m3/etcd"
  }
}

resource "aws_ebs_volume" "m3-etcd0-data" {
  availability_zone = "${data.aws_region.this.name}${element(module.integration.azs,0)}"
  encrypted         = true
  size              = "${var.m3-configuration["etcd-data-volume-gb"]}"
  type              = "gp2"
  
  tags = {
    Name        = "${var.environment}-m3-etcd0-data"
    Environment = "${var.environment}"
    Application = "M3"
    Volume      = "etcd0-data"
  }
}

resource "aws_volume_attachment" "m3-etcd0-data" {
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.m3-etcd0-data.id}"
  instance_id = "${aws_instance.m3-etcd0.id}"

  skip_destroy = true
}

resource "aws_cloudwatch_metric_alarm" "m3-etcd0-recovery" {
  alarm_name          = "${var.environment}-m3-etcd0-auto-recover"
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
    InstanceId = "${aws_instance.m3-etcd0.id}"
  }
}