resource "aws_security_group_rule" "grafana-icmp-ping-reply-egress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"

  protocol  = "icmp"
  from_port = "0" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-dest-unreachable-egress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"

  protocol  = "icmp"
  from_port = "3" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-ping-request-egress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"

  protocol  = "icmp"
  from_port = "8" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-time_exceeded-egress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "egress"

  protocol  = "icmp"
  from_port = "11" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}


resource "aws_security_group_rule" "grafana-icmp-ping-reply-ingress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "ingress"

  protocol  = "icmp"
  from_port = "0" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-dest-unreachable-ingress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "ingress"

  protocol  = "icmp"
  from_port = "3" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-ping-request-ingress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "ingress"

  protocol  = "icmp"
  from_port = "8" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}

resource "aws_security_group_rule" "grafana-icmp-time_exceeded-ingress" {
  security_group_id = "${aws_security_group.grafana.id}"

  type = "ingress"

  protocol  = "icmp"
  from_port = "11" # ICMP type, or -1 for all types
  to_port   = "-1" # ICMP code, or -1 for all codes for a specific type (not the same as AWS CLI docs state)

  cidr_blocks = ["${var.all-internal-network-cidr-block}"]
}