data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    // we pull this from another state
  }
}

output "vpc_id" {
  value = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "private_subnets" {
  value = ["${data.terraform_remote_state.vpc.private_subnets}"]
}

output "public_subnets" {
  value = ["${data.terraform_remote_state.vpc.public_subnets}"]
}

output "vpc_cidr" {
  value = "${data.terraform_remote_state.vpc.cidr_block}"
}

output "azs" {
  value = ["${data.terraform_remote_state.vpc.azs}"]
}

output "private_fixed_subnets" {
  value = ["${data.terraform_remote_state.vpc.private_fixed_subnets}"]
}

output "private_fixed_route_tables" {
  value = ["${data.terraform_remote_state.vpc.private_fixed_route_tables}"]
}

output "dns-private-forward-zone-id" {
  value = "${data.terraform_remote_state.vpc.dns-private-forward-zone-id}"
}

data "aws_route53_zone" "private-forward-zone" {
  zone_id = "${data.terraform_remote_state.vpc.dns-private-forward-zone-id}"
}

output "dns-private-forward-zone-name" {
  value = "${data.aws_route53_zone.private-forward-zone.name}"
}

output "dns-private-reverse-zone-id" {
  value = "${data.terraform_remote_state.vpc.dns-private-reverse-zone-id}"
}

data "aws_route53_zone" "private-reverse-zone" {
  zone_id = "${data.terraform_remote_state.vpc.dns-private-reverse-zone-id}"
}

output "dns-private-reverse-zone-name" {
  value = "${data.aws_route53_zone.private-reverse-zone.name}"
}

data "aws_subnet" "private-fixed-subnets" {
  count = 3
  id = "${element(data.terraform_remote_state.vpc.private_fixed_subnets,count.index)}"
}

output "private_fixed_subnet_cidrs" {
  value = ["${data.aws_subnet.private-fixed-subnets.*.cidr_block}"]
}