/*
 Terraform 0.11.* doesn't support dynamic list of maps.
 The proposed hack will create and inject this list of maps from a list of string.
 In order to create a dynamic list of instance types in the autoscaling group
 We use an intermediate null_data_source in order to transform an array of string to a list of map
 links:
  - https://github.com/HENNGE/terraform-aws-autoscaling-mixed-instances/blob/master/locals.tf#L17
  - https://github.com/HENNGE/terraform-aws-autoscaling-mixed-instances/blob/master/main.tf#L77

 INPUT: ["t1.micro", "t2.micro", "m5.large"]
 OUTPUT:
 ...
 override {
   instance_type = "t1.micro",
 }

 override {
   instance_type = "t2.micro",
 }

 override {
   instance_type = "m5.large",
 }
*/
data "null_data_source" "m3-query-instance-types" {
  count = "${length(var.m3-query-spot-instance-types)}"

  inputs = "${map(
    "instance_type", trimspace(element(var.m3-query-spot-instance-types, count.index))
  )}"
}

resource "aws_autoscaling_group" "m3-query" {

  name = "${var.environment}-m3-query"

  min_size = "${var.m3-configuration["query-pool-min-size"]}"
  max_size = "${var.m3-configuration["query-pool-max-size"]}"

  health_check_grace_period = 120
  health_check_type         = "EC2" # ELB once ELB is added
  default_cooldown          = 180

  force_delete = false

  target_group_arns = ["${aws_lb_target_group.internal-ingress-m3-query.arn}"]

  vpc_zone_identifier = ["${slice(module.integration.private_subnets,0,3)}"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 1
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = "${var.m3-configuration["query-spot-max-price"]}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.m3-query.id}"
        version = "$$Latest"
      }
      override = ["${data.null_data_source.m3-query-instance-types.*.outputs}"]
    }
  }

  tag {
    key                  = "Name"
    value                = "${var.environment}-m3-query"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Environment"
    value                = "${var.environment}"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Application"
    value                = "M3"
    propagate_at_launch  = true
  }

  tag {
    key                  = "AutoScalingGroupName"
    value                = "${var.environment}-m3-query"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.m3.port"
    value                = "7203"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.node-exporter.port"
    value                = "9100"
    propagate_at_launch  = true
  }
}

resource "aws_launch_template" "m3-query" {
  name = "${var.environment}-m3-query"

  credit_specification {
    cpu_credits = "unlimited"
  }
  
  iam_instance_profile {
    name = "${aws_iam_instance_profile.m3-query.name}"
  }

  image_id = "${var.m3-configuration["query-ami"]}"

  vpc_security_group_ids = [
    "${aws_security_group.m3-query.id}",
  ]

  key_name  = "${var.m3-configuration["query-ec2-key-name"]}"
  user_data = "${base64encode(data.template_file.m3-query-userdata-template.rendered)}"
}

data "template_file" "m3-query-userdata-template" {
  template = "${file("content/m3/query/cloudinit.yml")}"

  vars = {

    launch-script     = "${base64encode(file("content/m3/query/launch"))}"

    etcd-release-s3-uri = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["query-etcd-binary-key"]}"
    m3-release-s3-uri   = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.m3-configuration["query-m3-binary-key"]}"

    node-exporter-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.m3-configuration["query-node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    update-auto-reboot-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/update-auto-reboot"

    m3-query-config-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/${aws_s3_bucket_object.m3-query-config.key}"
  }
}

data "template_file" "m3-query-config" {
  template = "${file("content/m3/query/config.yml")}"

  vars {
    etcd-hostip0 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,0), 32)}"
    etcd-hostip1 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,1), 32)}"
    etcd-hostip2 = "${cidrhost(element(module.integration.private_fixed_subnet_cidrs,2), 32)}"
  }
}

resource "aws_s3_bucket_object" "m3-query-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "m3/query/config.yml"
  content = "${data.template_file.m3-query-config.rendered}"
  acl     = "private"
}
