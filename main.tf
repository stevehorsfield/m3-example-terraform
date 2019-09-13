terraform {
  backend "s3" {
    bucket  = "some-s3-state-bucket"
    key     = "some-s3-state-file"
    region  = "us-east-1"
    encrypt = "true"
  }
}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"

  version = "~> 2.0"
}

provider "random" {}

data "aws_region" "this" { }
data "aws_caller_identity" "this" { }
