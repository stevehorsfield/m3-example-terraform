resource "aws_security_group" "prometheus" {
  name   = "${var.environment}-prometheus"
  vpc_id = "${module.integration.vpc_id}"

  tags {
    Name        = "${var.environment}-prometheus"
    Environment = "${var.environment}"
    Application = "prometheus"
  }
}

resource "aws_security_group_rule" "prometheus-mtu-discovery" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type = "ingress"
  protocol = "icmp"
  from_port = 3 # ICMP type - Destination Unreachable
  to_port = 4 # ICMP code - Fragmentation Needed and Don't Fragment was Set
  description = "inbound mtu discovery"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-dns-udp" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-dns-tcp" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 53
  to_port = 53
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-ntp-udp" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-ntp-tcp" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 123
  to_port = 123
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-ssh" {
  security_group_id = "${aws_security_group.prometheus.id}"

  type = "ingress"
  from_port = 22
  protocol = "tcp"
  to_port = 22
  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "prometheus-allow-http" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus-allow-https" {

  security_group_id = "${aws_security_group.prometheus.id}"

  type = "egress"
  from_port = 443
  protocol = "tcp"
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"] # require access to S3 and so cannot constraint outbound access
}

resource "aws_security_group_rule" "prometheus-node-exporter-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of Prometheus nodes"

  type      = "egress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"
  self      = "true"
}

resource "aws_security_group_rule" "prometheus-node-exporter-scraping-self-ingress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus node-exporter scraping of Prometheus nodes"

  type      = "ingress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"
  self      = "true"
}

resource "aws_security_group_rule" "prometheus-native-scraping-self-ingress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus native scraping of Prometheus nodes"

  type      = "ingress"
  from_port = "9090"
  to_port   = "9090"
  protocol  = "tcp"
  self      = "true"
}

resource "aws_security_group_rule" "prometheus-native-scraping-self-egress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus native scraping of Prometheus nodes"

  type      = "egress"
  from_port = "9090"
  to_port   = "9090"
  protocol  = "tcp"
  self      = "true"
}

################# M3 configuration

resource "aws_security_group_rule" "prometheus-m3-coordinator-etcd-egress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "M3 etcd traffic outbound"

  type      = "egress"
  from_port = "2379"
  to_port   = "2379"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-etcd.id}"
}

resource "aws_security_group_rule" "prometheus-m3-coordinator-data-egress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus M3 Coordinator to send data to M3 (also supports M3DB metric scraping)"

  type      = "egress"
  from_port = "9000"
  to_port   = "9000"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-data.id}"
}

resource "aws_security_group_rule" "prometheus-m3-query-native-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of M3 query nodes"

  type      = "egress"
  from_port = "7203"
  to_port   = "7203"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-query.id}"
}

resource "aws_security_group_rule" "prometheus-m3-query-node-exporter-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of M3 query nodes"

  type      = "egress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.m3-query.id}"
}

resource "aws_security_group_rule" "prometheus-m3-data-native-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of M3 data nodes"

  type      = "egress"
  from_port = "9004"
  to_port   = "9004"
  protocol  = "tcp"
  
  source_security_group_id = "${aws_security_group.m3-data.id}"
}

resource "aws_security_group_rule" "prometheus-m3-etcd-node-exporter-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of M3 etcd nodes"

  type      = "egress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.m3-etcd.id}"
}

resource "aws_security_group_rule" "prometheus-m3-data-node-exporter-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of M3 data nodes"

  type      = "egress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.m3-data.id}"
}

resource "aws_security_group_rule" "prometheus-m3-coordinator-metric-scraping-egress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of local M3 coordinators"

  type      = "egress"
  from_port = "7203"
  to_port   = "7203"
  protocol  = "tcp"
  self      = "true"
}

resource "aws_security_group_rule" "prometheus-m3-coordinator-metric-scraping-ingress" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of local M3 coordinators"

  type      = "ingress"
  from_port = "7203"
  to_port   = "7203"
  protocol  = "tcp"
  self      = "true"
}

resource "aws_security_group_rule" "prometheus-grafana-native-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of Grafana nodes"

  type      = "egress"
  from_port = "3000"
  to_port   = "3000"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "prometheus-grafana-node-exporter-metric-scraping" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow Prometheus metric scraping of Grafana nodes"

  type      = "egress"
  from_port = "9100"
  to_port   = "9100"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "prometheus-promql-grafana" {
  security_group_id = "${aws_security_group.prometheus.id}"

  description = "Allow direct Prometheus querying from Grafana"

  type      = "ingress"
  from_port = "9090"
  to_port   = "9090"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.grafana.id}"
}

