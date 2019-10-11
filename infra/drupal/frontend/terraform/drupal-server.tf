######################## Provider ##############################################

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

######################## Remote states #########################################

terraform {
  backend "s3" {}
  required_version = "0.12.3"
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

resource "aws_security_group" "drupal-server" {
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

resource "aws_security_group_rule" "allow_alb_to_server" {
  type      = "ingress"
  from_port = "${var.instances_port}"
  to_port   = "${var.instances_port}"
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.drupal-server.id}"
  source_security_group_id = "${aws_security_group.alb.id}"
}

############################# EC2 Instance #####################################

resource "aws_ebs_volume" "drupal-server-ebs" {
  availability_zone = "${element(data.terraform_remote_state.vpc.outputs.vpc_azs, 2)}"
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

resource "aws_instance" "drupal-server" {
  ami                  = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  subnet_id            = "${element(data.terraform_remote_state.vpc.outputs.private_subnets, 2)}"
  availability_zone    = "${element(data.terraform_remote_state.vpc.outputs.vpc_azs, 2)}"
  key_name             = "${var.key_name}"
  user_data            = "${data.template_file.user_data_file.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.drupal-server.name}"

  vpc_security_group_ids = [
    "${aws_security_group.drupal-server.id}",
    "${data.terraform_remote_state.vpc.outputs.sg_ssh_from_bastion}",
  ]

  /* Common tags */
  tags = {
    AMI         = "${var.ami_id}"
    Name        = "${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

resource "aws_volume_attachment" "drupal-server-ebs-att" {
  device_name  = "${var.ebs_device_name}"
  volume_id    = "${aws_ebs_volume.drupal-server-ebs.id}"
  instance_id  = "${aws_instance.drupal-server.id}"
  skip_destroy = true
}

############################# ALB ##############################################

# Create web ELB security group
resource "aws_security_group" "alb" {
  name        = "sgp-alb-${var.service_name}-${var.role}"
  description = "SG ALB ${var.service_name}-${var.role}"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  ingress {
    from_port   = "${var.alb_port_secure}"
    to_port     = "${var.alb_port_secure}"
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = "${var.alb_port}"
    to_port     = "${var.alb_port}"
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sgp-alb-${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

resource "aws_alb" "drupal-server" {
  name            = "alb-${var.service_name}-${var.role}"
  subnets         = "${data.terraform_remote_state.vpc.outputs.public_subnets}"
  security_groups = ["${aws_security_group.alb.id}"]

  tags = {
    Name        = "alb-${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

# resource "aws_alb_listener" "drupal-server-https" {
#   load_balancer_arn = "${aws_alb.drupal-server.arn}"
#   port              = "${var.alb_port_secure}"
#   protocol          = "${var.alb_protocol_secure}"
#   ssl_policy        = "ELBSecurityPolicy-2015-05"
#   certificate_arn   = "${var.alb_ssl_certificate_id}"

#   default_action {
#     target_group_arn = "${aws_alb_target_group.drupal-server-https.arn}"
#     type             = "forward"
#   }
# }

resource "aws_alb_listener" "drupal-server-http" {
  load_balancer_arn = "${aws_alb.drupal-server.arn}"
  port              = "${var.alb_port}"
  protocol          = "${var.alb_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.drupal-server-http.arn}"
    type             = "forward"
  }
}

resource "random_id" "target_group_name" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    secure_port = "${var.instances_port_secure}"
    protocol = "${var.instances_protocol_secure}"
    vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
    port     = "${var.instances_port}"
    protocol_secure            = "${var.instances_protocol_secure}"
  }
  byte_length = 4
}

# resource "aws_alb_target_group" "drupal-server-https" {
#   name     = "tg-${var.service_name}-${var.role}-https-${random_id.target_group_name.hex}"
#   port     = "${var.instances_port_secure}"
#   protocol = "${var.instances_protocol_secure}"
#   vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

#   health_check {
#     healthy_threshold   = "2"
#     unhealthy_threshold = "2"
#     timeout             = "2"
#     interval            = "5"
#     path                = "/"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_alb_target_group" "drupal-server-http" {
  name     = "tg-${var.service_name}-${var.role}-http-${random_id.target_group_name.hex}"
  port     = "${var.instances_port}"
  protocol = "${var.instances_protocol}"
  vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    port                = "${var.instances_port_secure}"
    protocol            = "${var.instances_protocol_secure}"
    timeout             = "2"
    interval            = "5"
    path                = "/"
    matcher             = "200,301"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_alb_target_group_attachment" "drupal-server-https" {
#   target_group_arn = "${aws_alb_target_group.drupal-server-https.arn}"
#   target_id        = "${aws_instance.drupal-server.id}"
#   port             = "${var.instances_port_secure}"
# }

resource "aws_alb_target_group_attachment" "drupal-server-http" {
  target_group_arn = "${aws_alb_target_group.drupal-server-http.arn}"
  target_id        = "${aws_instance.drupal-server.id}"
  port             = "${var.instances_port}"
}

######################## IAM Instance Profile ##################################

# IAM Instance Profile
resource "aws_iam_instance_profile" "drupal-server" {
  name  = "${var.service_name}-${var.role}-profile"
  roles = ["${aws_iam_role.drupal-server.name}"]
}

# IAM Role
resource "aws_iam_role" "drupal-server" {
  name = "${var.service_name}-${var.role}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "read_ssh_keys" {
  name = "${var.service_name}-${var.role}-read_ssh_keys"
  role = "${aws_iam_role.drupal-server.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListUsers"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetSSHPublicKey",
                "iam:ListSSHPublicKeys"
            ],
            "Resource": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
            ]
        },
        {
              "Action": "s3:*",
              "Effect": "Allow",
              "Resource": "arn:aws:s3:::tiime-drupal-blob"
        }
    ]
}
EOF
}

######################## Route 53 ##############################################

# resource "aws_route53_record" "alb_public_alias" {
#   zone_id = "${data.terraform_remote_state.vpc.outputs.public_host_zone}"
#   name    = "${var.service_name}"
#   type    = "${var.alb_public_alias_record_type}"
#   ttl     = "${var.alb_public_alias_ttl}"
#   records = ["${aws_alb.drupal-server.dns_name}"]
# }

######################## Module Outputs ########################################

# output "drupal_hostname" {
#   value = "${aws_route53_record.alb_public_alias.fqdn}"
# }

output "drupal_port" {
  value = "${var.alb_port_secure}"
}

output "drupal_srv_sg" {
  value = "${aws_security_group.drupal-server.id}"
}

output "alb_sg" {
  value = "${aws_security_group.alb.id}"
}
