# HTTP listener on 7201
resource "aws_lb_listener" "internal-ingress-m3-query" {
  load_balancer_arn = "${aws_lb.internal-ingress.arn}"
  protocol          = "HTTP"

  port              = 7201

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 - Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "m3-query" {
  listener_arn = "${aws_lb_listener.internal-ingress-m3-query.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal-ingress-m3-query.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.internal-ingress-m3-query.name}"]
  }
}

resource "aws_lb_target_group" "internal-ingress-m3-query" {
  name        = "${var.environment-short-name}-int-m3-query"
  protocol    = "HTTP"
  port        = "7201"
  target_type = "instance"
  vpc_id      = "${module.integration.vpc_id}"

  health_check {
    interval            = 30
    path                = "/metrics"
    port                = "7203"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_route53_record" "internal-ingress-m3-query" {
  zone_id = "${data.aws_route53_zone.forward-local.zone_id}"
  name    = "m3-query.${data.aws_route53_zone.forward-local.name}"
  type    = "A"

  alias {
    name    = "${aws_lb.internal-ingress.dns_name}"
    zone_id = "${aws_lb.internal-ingress.zone_id}"
    evaluate_target_health = false
  }
}
