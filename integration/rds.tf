data "terraform_remote_state" "rds" {
  backend = "s3"

  config {
    // we pull this from another state
  }
}

output "rds-endpoint" {
  value = "${data.terraform_remote_state.rds.endpoint}"
}

output "rds-security-group" {
  value = "${data.terraform_remote_state.rds.security-group}"
}