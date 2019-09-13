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
data "null_data_source" "grafana-instance-types" {
  count = "${length(var.grafana-spot-instance-types)}"

  inputs = "${map(
    "instance_type", trimspace(element(var.grafana-spot-instance-types, count.index))
  )}"
}

resource "aws_autoscaling_group" "grafana" {

  name = "${var.environment}-grafana"

  min_size = "${var.grafana-configuration["grafana-pool-min-size"]}"
  max_size = "${var.grafana-configuration["grafana-pool-max-size"]}"

  health_check_grace_period = 120
  health_check_type         = "EC2" # ELB once ELB is added
  default_cooldown          = 0

  force_delete = false

  target_group_arns = ["${aws_lb_target_group.internal-ingress-grafana.arn}"]

  vpc_zone_identifier = ["${slice(module.integration.private_subnets,0,3)}"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 1
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = "${var.grafana-configuration["grafana-spot-max-price"]}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.grafana.id}"
        version = "$$Latest"
      }
      override = ["${data.null_data_source.grafana-instance-types.*.outputs}"]
    }
  }

  tag {
    key                  = "Name"
    value                = "${var.environment}-grafana"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Environment"
    value                = "${var.environment}"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Application"
    value                = "grafana"
    propagate_at_launch  = true
  }

  tag {
    key                  = "AutoScalingGroupName"
    value                = "${var.environment}-grafana"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.grafana.port"
    value                = "3000"
    propagate_at_launch  = true
  }

  tag {
    key                  = "prometheus.scraping.node-exporter.port"
    value                = "9100"
    propagate_at_launch  = true
  }
}

resource "aws_launch_template" "grafana" {
  name = "${var.environment}-grafana"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.grafana.name}"
  }

  image_id = "${var.grafana-configuration["grafana-ami-id"]}"

  vpc_security_group_ids = [
    "${aws_security_group.grafana.id}",
  ]

  key_name  = "${var.grafana-configuration["grafana-ec2-key-name"]}"
  user_data = "${base64encode(data.template_file.grafana-userdata-template.rendered)}"
}

data "template_file" "grafana-userdata-template" {
  template = "${file("content/grafana/cloudinit.yml")}"

  vars = {

    launch-script     = "${base64encode(file("content/grafana/launch"))}"

    grafana-release-s3-uri = "s3://${aws_s3_bucket.distribution-artefacts.id}/${var.grafana-configuration["grafana-binary-key"]}"
    grafana-config-s3-uri  = "s3://${aws_s3_bucket.system-configuration.id}/${aws_s3_bucket_object.grafana-config.key}"

    node_exporter-release-s3-uri            = "s3://${aws_s3_bucket.distribution-artefacts.bucket}/${var.grafana-configuration["node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    update-auto-reboot-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/update-auto-reboot"

    kms_region   = "${data.aws_region.this.name}"
  }
}

data "template_file" "grafana-config" {
  template = "${file("content/grafana/config.ini")}"

  vars {
    rds-endpoint = "${module.integration.rds-endpoint}"

    public-url-with-trailing-slash = "https://${var.grafana-configuration["grafana-hostname"]}/"
  }
}

resource "aws_s3_bucket_object" "grafana-config" {
  bucket  = "${aws_s3_bucket.system-configuration.id}"
  key     = "grafana/grafana.ini"
  content = "${data.template_file.grafana-config.rendered}"
  acl     = "private"
}

resource "aws_kms_grant" "grafana-credentials-postgres-password" {
  name   = "${var.environment}-grafana-aws-credentials"
  key_id = "${aws_kms_key.secrets.id}"
  grantee_principal = "${aws_iam_role.grafana.arn}"
  operations = ["Decrypt"]

  constraints {
    encryption_context_equals {
      Application = "grafana"
      SecretName  = "grafana-credentials-postgres-password"
    }
  }
}