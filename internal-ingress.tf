resource "aws_lb" "internal-ingress" {
  name                       = "${var.environment-short-name}-internal-ingress"
  internal                   = true
  load_balancer_type         = "application"
  enable_deletion_protection = false
  idle_timeout               = 300
  enable_http2               = true
  ip_address_type            = "ipv4"
  subnets                    = ["${slice(module.integration.private_subnets,0,3)}"]
  security_groups            = [
    "${aws_security_group.internal-ingress-alb.id}",
  ]

  access_logs {
    bucket  = "${aws_s3_bucket.access-logs.id}"
    prefix  = "internal-ingress-alb"
    enabled = true
  }

  tags {
    Name        = "${var.environment}-internal-ingress"
    Environment = "${var.environment}"
    Application = "internal-ingress"
  }
}

# HTTP listener on 80
resource "aws_lb_listener" "internal-ingress-http" {
  load_balancer_arn = "${aws_lb.internal-ingress.arn}"
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS is intended but to reduce complexity will be deployed as HTTP first
resource "aws_lb_listener" "internal-ingress-https" {
  load_balancer_arn = "${aws_lb.internal-ingress.arn}"
  protocol          = "HTTPS"

  certificate_arn   = "${var.internal-ingress-cert-arn}"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # recommended default, not most secure
  port              = 443

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 - Not found"
      status_code  = "404"
    }
  }
}

resource "aws_route53_record" "internal-ingress" {
  zone_id = "${data.aws_route53_zone.forward-local.zone_id}"
  name    = "internal-ingress.${data.aws_route53_zone.forward-local.name}"
  type    = "A"

  alias {
    name    = "${aws_lb.internal-ingress.dns_name}"
    zone_id = "${aws_lb.internal-ingress.zone_id}"
    evaluate_target_health = false
  }
}
