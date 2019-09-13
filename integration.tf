module "integration" {
  source = "./integration"

  environment            = "${var.environment}"
  environment-short-name = "${var.environment-short-name}"

  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"

  remote-state-bucket = "${var.remote-state-bucket}"
  remote-state-region = "${var.remote-state-region}"
}