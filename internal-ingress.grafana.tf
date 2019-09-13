resource "aws_lb_listener_rule" "grafana" {
  listener_arn = "${aws_lb_listener.internal-ingress-https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal-ingress-grafana.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.grafana-configuration["grafana-hostname"]}"]
  }
}

resource "aws_lb_target_group" "internal-ingress-grafana" {
  name        = "${var.environment-short-name}-int-grafana"
  protocol    = "HTTP"
  port        = "3000"
  target_type = "instance"
  vpc_id      = "${module.integration.vpc_id}"

  health_check {
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}
