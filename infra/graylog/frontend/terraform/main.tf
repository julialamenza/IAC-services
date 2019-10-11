######################## Provider ##############################################

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

######################## Remote states #########################################

terraform {
  backend "s3" {}
  required_version = "0.12.6"
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

data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    bucket = "${var.state_bucket}"
    key    = "${var.backend_state_key}"
    region = "${var.region}"
  }
}
#### IAM
resource "aws_iam_instance_profile" "app" {
  name = "${var.service_name}-graylog-instprofile"
  role = "${aws_iam_role.app_instance.name}"
}

resource "aws_iam_role" "app_instance" {
  name = "${var.service_name}-graylog-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance" {
  name   = "graylog_role"
  role   = "${aws_iam_role.app_instance.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}

data "template_file" "instance_profile" {
  template = "${file("${path.module}/graylog-instance.json")}"
}

##############################################################

######################### EC2 ##################################################

resource "aws_instance" "graylog" {
  ami                    = "ami-0007c0e7d6b2985bb"
  instance_type          = "${var.graylog_instance_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${element(data.terraform_remote_state.vpc.outputs.public_subnets, 0)}"
  iam_instance_profile   = "${aws_iam_instance_profile.app.name}"

  
  vpc_security_group_ids = [
    "${aws_security_group.graylog-ec2.id}",
    "${data.terraform_remote_state.vpc.outputs.sg_ssh_from_bastion}",
  ]

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "Graylog-Server"
  }
}
