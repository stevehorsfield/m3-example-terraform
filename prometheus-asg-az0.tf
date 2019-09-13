resource "aws_autoscaling_group" "prometheus0" {

  name = "${var.environment}-prometheus0"

  desired_capacity = 1 # we are using auto scaling for spot fleet
  min_size = 1
  max_size = 1

  health_check_grace_period = 300
  health_check_type         = "EC2"
  default_cooldown          = 0

  force_delete = false

  vpc_zone_identifier = ["${module.integration.private_subnets[0]}"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 1
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = "${var.prometheus-configuration["spot_max_price"]}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.prometheus0.id}"
        version = "$$Latest"
      }
      override = ["${data.null_data_source.prometheus-instance_types.*.outputs}"]
    }
  }

  tag {
    key                  = "Name"
    value                = "${var.environment}-prometheus0"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Environment"
    value                = "${var.environment}"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Application"
    value                = "prometheus"
    propagate_at_launch  = true
  }

  tag {
    key                  = "VpcHostname"
    value                = "prometheus0"
    propagate_at_launch  = true
  }

  tag {
    key                  = "AutoScalingGroupName"
    value                = "${var.environment}-prometheus0"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.node-exporter.port"
    value                = "9100"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.prometheus.port"
    value                = "9090"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.m3.port"
    value                = "7203"
    propagate_at_launch  = true
  }
}

resource "aws_launch_template" "prometheus0" {
  name = "${var.environment}-prometheus0"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.prometheus.name}"
  }

  image_id               = "${var.prometheus-configuration["ami_id"]}"

  vpc_security_group_ids = [
    "${aws_security_group.prometheus.id}",
  ]

  key_name  = "${var.prometheus-configuration["ec2-key-name"]}"
  user_data = "${base64encode(data.template_file.prometheus0.rendered)}"
}

data "template_file" "prometheus0" {
  template = "${file("content/prometheus/prometheus.cloudinit.yml")}"

  vars = {

    hostname-manager-unit-file           = "${base64encode(file("content/hostname-manager/hostname-manager.service"))}"
    hostname-manager-apply-hostname-file = "${base64encode(file("content/hostname-manager/apply-hostname"))}"

    filesystems-attach-volume-file        = "${base64encode(file("content/filesystems/attach-volume"))}"
    filesystems-check-and-mount-file      = "${base64encode(file("content/filesystems/check-and-mount"))}"
    filesystems-format-if-empty-file      = "${base64encode(file("content/filesystems/format-if-empty"))}"
    filesystems-create-secret-folder-file = "${base64encode(file("content/filesystems/create-secret-folder"))}"

    prometheus-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.prometheus-configuration["prometheus-binary-key"]}"
    prometheus-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/prometheus"

    node-exporter-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.prometheus-configuration["node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    m3-release-s3-uri                        = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["coordinator-m3-binary-key"]}"
    m3-coordinator-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/m3"

    yq-release-s3-uri = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.prometheus-configuration["yq-binary-key"]}"

    launch-script     = "${base64encode(file("content/prometheus/prometheus-launch"))}"
    volume-id         = "${aws_ebs_volume.prometheus0.id}"
    hostname          = "prometheus0.${module.integration.dns-private-forward-zone-name}"
  }
}

resource "aws_ebs_volume" "prometheus0" {
  availability_zone = "us-east-1a"
  size              = "${var.prometheus-configuration["storage-size-gb"]}"
  type              = "gp2"

  tags {
    Name        = "${var.environment}-prometheus0-data"
    Environment = "${var.environment}"
    Application = "prometheus"
    Volume      = "prometheus0-data"
  }
}
