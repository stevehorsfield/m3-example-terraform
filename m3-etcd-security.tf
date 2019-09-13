resource "aws_security_group" "m3-etcd" {
  name   = "${var.environment}-m3-etcd"
  vpc_id = "${module.integration.vpc_id}"

  tags {
    Name        = "${var.environment}-m3-etcd"
    Environment = "${var.environment}"
    Application = "M3"
  }
}

resource "aws_security_group_rule" "m3-etcd-allow-dns-udp" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-etcd-allow-dns-tcp" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-etcd-allow-ntp-udp" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-etcd-allow-ntp-tcp" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "m3-etcd-allow-http" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-etcd-allow-https" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "egress"
  from_port = 443
  protocol = "tcp"
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"] # require access to updates, Docker images, etc.
}

resource "aws_security_group_rule" "m3-etcd-allow-ssh" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  type = "ingress"
  from_port = 22
  protocol = "tcp"
  to_port = 22
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "m3-etcd-etcd-self-protocols-ingress" {
  security_group_id = "${aws_security_group.m3-etcd.id}"
  
  description = "etcd traffic between cluster nodes"

  type      = "ingress"
  from_port = "2379"
  to_port   = "2380"
  protocol  = "tcp"
  self      = true
}

resource "aws_security_group_rule" "m3-etcd-etcd-self-protocols-egress" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  description = "etcd traffic between cluster nodes"

  type      = "egress"
  from_port = "2379"
  to_port   = "2380"
  protocol  = "tcp"
  self      = true
}

resource "aws_security_group_rule" "m3-etcd-etcd-ingress-m3-data" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  description = "etcd traffic from m3 data nodes"

  type      = "ingress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-data.id}"
}

resource "aws_security_group_rule" "m3-etcd-etcd-ingress-m3-query" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  description = "etcd traffic from m3 query nodes"

  type      = "ingress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-query.id}"
}

resource "aws_security_group_rule" "m3-etcd-etcd-ingress-prometheus" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  description = "etcd traffic from m3 coordinator on prometheus nodes" # Also allows scraping

  type      = "ingress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "m3-etcd-etcd-ingress-prometheus-node-exporter" {
  security_group_id = "${aws_security_group.m3-etcd.id}"

  description = "node-exporter scraping by Prometheus"

  type      = "ingress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.prometheus.id}"
}