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

######################## Security Group ########################################

resource "aws_security_group" "database" {
  name        = "sgp-${var.service_name}-${var.role}"
  description = "SG-${var.service_name}-${var.role}"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sgp-${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

resource "aws_security_group_rule" "allow_db_from_bastion" {
    type = "ingress"
    from_port = "27017"
    to_port = "27017"
    protocol = "TCP"

    security_group_id = "${aws_security_group.database.id}"
    source_security_group_id = "${data.terraform_remote_state.vpc.outputs.sg_ssh_to_bastion}"
}

######################## EBS ########################################

resource "aws_ebs_volume" "mongo-server-ebs" {
  availability_zone = "${element(data.terraform_remote_state.vpc.outputs.vpc_azs, 0)}"
  type              = "${var.ebs_type}"
  size              = "${var.ebs_size}"

  /* Common tags */
  tags = {
    Name        = "${var.service_name}-${var.role}-data"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

######################## MongoDB ########################################


data "template_file" "user_data_file" {
  template = "${file("userdata.tpl")}"

  vars = {
    role        = "${var.role}"
    environment = "${var.env}"
    # self_fqdn   = "${aws_route53_record.alb_public_alias.fqdn}"
    device_name = "${var.ebs_device_name}"
  }
}

resource "aws_volume_attachment" "mongo-server-ebs-att" {
  device_name  = "${var.ebs_device_name}"
  volume_id    = "${aws_ebs_volume.mongo-server-ebs.id}"
  instance_id  = "${aws_instance.mongo.id}"
  skip_destroy = true
}

resource "aws_instance" "mongo" {
  ami                  = "${var.mongo_ami}"
  instance_type        = "t2.large"
  key_name             = "${var.key_name}"
  subnet_id            = "${element(data.terraform_remote_state.vpc.outputs.private_subnets, 0)}"
  user_data            = "${data.template_file.user_data_file.rendered}"
  vpc_security_group_ids = [
    "${aws_security_group.database.id}",
    "${data.terraform_remote_state.vpc.outputs.sg_ssh_from_bastion}"
  ]
  
  tags = {
    Name = "${var.service_name}-mongo-${var.role}"
  }
}

# output "mongo_username" {
#   value = "${module.db.this_db_instance_username}"
# }

# output "mongo_password" {
#   value = "${module.db.this_db_instance_password}"
# }

# output "mongo_database" {
#   value = "${module.db.this_db_instance_name}"
# }

# output "mongo_port" {
#   value = "${module.db.this_db_instance_port}"
# }

# output "mongo_address" {
#   value = "${module.db.this_db_instance_address}"
# }

output "mongo_sg" {
  value = "${aws_security_group.database.id}"
}