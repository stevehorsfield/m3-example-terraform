resource "aws_security_group" "grafana" {
  name   = "${var.environment}-grafana"
  vpc_id = "${module.integration.vpc_id}"

  tags {
    Name        = "${var.environment}-grafana"
    Environment = "${var.environment}"
    Application = "grafana"
  }
}

resource "aws_security_group_rule" "grafana-allow-dns-udp" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "grafana-allow-dns-tcp" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "grafana-allow-ntp-udp" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "grafana-allow-ntp-tcp" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "grafana-allow-http" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "grafana-allow-https" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"
  from_port = 443
  protocol = "tcp"
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "grafana-allow-ssh" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "ingress"
  from_port = 22
  protocol = "tcp"
  to_port = 22
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-allow-postgres" {
  security_group_id = "${aws_security_group.grafana.id}"

  type        = "egress"
  from_port   = "5432"
  to_port     = "5432"
  protocol    = "tcp"
  cidr_blocks = ["${module.integration.vpc_cidr}"]              # Entire VPC; ideally this would be more restrictive
}

resource "aws_security_group_rule" "grafana-allow-m3" {
  security_group_id = "${aws_security_group.grafana.id}"

  type        = "egress"
  from_port   = "7201"
  to_port     = "7201"
  protocol    = "tcp"

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}

resource "aws_security_group_rule" "grafana-allow-web-ingress" {
  security_group_id = "${aws_security_group.grafana.id}"

  description = "Allow Grafana website access from ALB"

  type      = "ingress"
  from_port = "3000"
  to_port   = "3000"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}

resource "aws_security_group_rule" "grafana-node-exporter-metric-scraping-prometheus" {
  security_group_id = "${aws_security_group.grafana.id}"

  description = "Allow Prometheus metric scraping for node exporter"

  type      = "ingress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "grafana-native-metric-scraping-prometheus" {
  security_group_id = "${aws_security_group.grafana.id}"

  description = "Allow Prometheus metric scraping for Grafana"

  type      = "ingress"
  from_port = "3000"
  to_port   = "3000"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "grafana-promql-prometheus" {
  security_group_id = "${aws_security_group.grafana.id}"

  description = "Allow direct Prometheus querying from Grafana"

  type      = "egress"
  from_port = "9090"
  to_port   = "9090"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.prometheus.id}"
}

