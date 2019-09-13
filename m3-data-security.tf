resource "aws_security_group" "m3-data" {
  name   = "${var.environment}-m3-data"
  vpc_id = "${module.integration.vpc_id}"

  tags {
    Name        = "${var.environment}-m3-data"
    Environment = "${var.environment}"
    Application = "M3"
  }
}

resource "aws_security_group_rule" "m3-data-allow-dns-udp" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-data-allow-dns-tcp" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-data-allow-ntp-udp" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-data-allow-ntp-tcp" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-data-allow-http" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-data-allow-https" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "egress"
  from_port = 443
  protocol = "tcp"
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-data-allow-ssh" {
  security_group_id = "${aws_security_group.m3-data.id}"

  type = "ingress"
  from_port = 22
  protocol = "tcp"
  to_port = 22
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "m3-data-etcd-egress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "etcd traffic outbound"

  type      = "egress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-etcd.id}"
}

resource "aws_security_group_rule" "m3-data-internal-egress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 cluster traffic outbound"

  type      = "egress"
  from_port = "9000"
  to_port   = "9003"
  protocol  = "tcp"
  self      = true  
}

resource "aws_security_group_rule" "m3-data-internal-ingress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 cluster traffic inbound"

  type      = "ingress"
  from_port = "9000"
  to_port   = "9003"
  protocol  = "tcp"
  self      = true  
}

resource "aws_security_group_rule" "m3-data-query-ingress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 cluster traffic inbound from m3-query"

  type      = "ingress"
  from_port = "9000"
  to_port   = "9000"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-query.id}"
}

resource "aws_security_group_rule" "m3-data-prometheus-ingress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 cluster traffic inbound from m3-coordinator on prometheus nodes"

  type      = "ingress"
  from_port = "9000"
  to_port   = "9000"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "m3-data-prometheus-scraping-ingress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 metric scraping from prometheus nodes"

  type      = "ingress"
  from_port = "9004"
  to_port   = "9004"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "m3-data-prometheus-node-exporter-scraping-ingress" {
  security_group_id = "${aws_security_group.m3-data.id}"

  description = "m3 metric scraping from prometheus nodes"

  type      = "ingress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}