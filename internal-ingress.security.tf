resource "aws_security_group" "internal-ingress-alb" {
  vpc_id = "${module.integration.vpc_id}"
  name   = "${var.environment}-internal-ingress-alb"

  tags {
    Name        = "${var.environment}-internal-ingress-alb"
    Environment = "${var.environment}"
    Application = "internal-ingress"
  }
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-http" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["${module.integration.vpc_cidr}"]              # Entire VPC; ideally this would be more restrictive
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-https" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${module.integration.vpc_cidr}"]              # Entire VPC; ideally this would be more restrictive
}

resource "aws_security_group_rule" "internal-ingress-alb-inbound-http" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["${var.all-internal-network-cidr-block}"]                                  # Entire corporate network; filtering using WAF not security groups
}

resource "aws_security_group_rule" "internal-ingress-alb-inbound-https" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTPS ports on instances etc."
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${var.all-internal-network-cidr-block}"]                                  # Entire corporate network; filtering using WAF not security groups
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-grafana" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to Grafana target groups"

  type              = "egress"
  from_port         = "3000"
  to_port           = "3000"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-inbound-m3-query" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow traffic from Grafana"

  type              = "ingress"
  from_port         = "7201"
  to_port           = "7201"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.grafana.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-m3-query" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to M3 Query target groups"

  type              = "egress"
  from_port         = "7201"
  to_port           = "7201"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.m3-query.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-m3-query-health-check" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to M3 Query target groups"

  type              = "egress"
  from_port         = "7203"
  to_port           = "7203"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.m3-query.id}"
}