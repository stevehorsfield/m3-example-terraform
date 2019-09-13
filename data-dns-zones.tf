data "aws_route53_zone" "forward-local" {
  name         = "${var.environment-short-name}.example.local."
  vpc_id       = "${module.integration.vpc_id}"
  private_zone = true
}
