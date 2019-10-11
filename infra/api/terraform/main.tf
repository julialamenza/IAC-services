######################## Provider ##############################################

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

######################## Remote states #########################################

terraform {
  backend "s3" {}
}

# Reference VPC state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.state_bucket}"
    key    = "${var.vpc_state_key}"
    region = "${var.region}"
  }
}