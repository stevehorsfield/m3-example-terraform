resource "aws_security_group" "m3-query" {
  name   = "${var.environment}-m3-query"
  vpc_id = "${module.integration.vpc_id}"

  tags {
    Name        = "${var.environment}-m3-query"
    Environment = "${var.environment}"
    Application = "M3"
  }
}

resource "aws_security_group_rule" "m3-query-allow-dns-udp" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-query-allow-dns-tcp" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-query-allow-ntp-udp" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-query-allow-ntp-tcp" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-query-allow-http" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-query-allow-https" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "egress"
  from_port = 443
  protocol = "tcp"
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-query-allow-ssh" {
  security_group_id = "${aws_security_group.m3-query.id}"

  type = "ingress"
  from_port = 22
  protocol = "tcp"
  to_port = 22
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "m3-query-etcd-egress" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "etcd traffic outbound"

  type      = "egress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-etcd.id}"
}

resource "aws_security_group_rule" "m3-query-data-egress" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "M3 data traffic outbound"

  type      = "egress"
  from_port = "9000"
  to_port   = "9000"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-data.id}"
}

resource "aws_security_group_rule" "m3-query-native-metric-scraping-prometheus" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "Allow Prometheus metric scraping"

  type      = "ingress"
  from_port = "7203"
  to_port   = "7203"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "m3-query-node-exporter-metric-scraping-prometheus" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "Allow Prometheus metric scraping for node exporter"

  type      = "ingress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "m3-query-promql-temp-anywhere" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "TEMPORARY - allow querying from any internal host"

  type      = "ingress"
  from_port = "7201"
  to_port   = "7201"
  protocol  = "tcp"
  
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "m3-query-ingress-traffic-alb" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "Allow ALB ingress traffic"

  type      = "ingress"
  from_port = "7201"
  to_port   = "7201"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}

resource "aws_security_group_rule" "m3-query-health-check-alb" {
  security_group_id = "${aws_security_group.m3-query.id}"

  description = "Allow ALB health check"

  type      = "ingress"
  from_port = "7203"
  to_port   = "7203"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}
