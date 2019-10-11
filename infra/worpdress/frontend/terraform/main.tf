######################## Provider ##############################################

provider "aws" { region = "${var.region}" }
data "aws_caller_identity" "current" {}

######################## Remote states #########################################

terraform {
  backend "s3" {
  }
}

# Reference VPC state file
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.state_bucket}"
    key = "${var.vpc_state_key}"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket = "${var.state_bucket}"
    key = "${var.backend_state_key}"
    region = "${var.region}"
  }
}

resource "aws_ecr_repository" "ecs_repo" {
  name = "${var.service_name}"
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = "${aws_ecr_repository.ecs_repo.name}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.app_instance.arn}",
                "Service": "ecs.amazonaws.com"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "${var.service_name}-asg"
  vpc_zone_identifier  = "${data.terraform_remote_state.vpc.outputs.private_subnets}"
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.app.name}"
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars = {
    aws_region         = "${var.region}"
    ecs_cluster_name   = "${aws_ecs_cluster.main.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
    ecs_log_group_name = "${aws_cloudwatch_log_group.ecs.name}"
  }
}

data "aws_ami" "stable_coreos" {
  most_recent = true

  filter {
    name   = "description"
    values = ["CoreOS Container Linux stable *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

resource "aws_launch_configuration" "app" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
    "${data.terraform_remote_state.vpc.outputs.sg_ssh_from_bastion}",
  ]

  name_prefix                 = "ecs-${var.service_name}"
  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.cloud_config.rendered}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

### Security

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  name        = "ecs-${var.service_name}-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "lb_sg" {
  description = "controls direct access to load-balancer"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  name        = "ecs-${var.service_name}-lbsg"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## ECS

resource "aws_ecs_cluster" "main" {
  name = "ecs_${var.service_name}_cluster"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars = {
    image_url        = "389278454829.dkr.ecr.eu-west-3.amazonaws.com/wordpress:02e71b4409b56cf526ef13682bd1661b96268b8f"
    #image_url        = "${aws_ecr_repository.ecs_repo.repository_url}:${var.container_version}"
    container_name   = "${var.service_name}"
    log_group_region = "${var.region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
    db_name          = "${data.terraform_remote_state.backend.outputs.rds_database}"
    db_user          = "${data.terraform_remote_state.backend.outputs.rds_username}"
    db_password      = "${data.terraform_remote_state.backend.outputs.rds_password}"
    db_host          = "${data.terraform_remote_state.backend.outputs.rds_address}"
    db_prefix        = "wp_"
    wp_env           = "staging"
    wp_home          = "https://butlercorum-am.com"
    wp_siteurl       = "https://butlercorum-am.com/wp"
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                = "${var.service_name}_td"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "wordpress" {
  name            = "ecs-${var.service_name}"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.wordpress.arn}"
  desired_count   = 1
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = "${aws_alb_target_group.tg_web.id}"
    container_name   = "${var.service_name}"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb.main"
  ]
}

## IAM

resource "aws_iam_role" "ecs_service" {
  name = "${var.service_name}_ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service" {
  name = "${var.service_name}_ecs_policy"
  role = "${aws_iam_role.ecs_service.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.service_name}-ecs-instprofile"
  role = "${aws_iam_role.app_instance.name}"
}

resource "aws_iam_role" "app_instance" {
  name = "${var.service_name}-ecs-instance-role"

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

data "template_file" "instance_profile" {
  template = "${file("${path.module}/instance-profile-policy.json")}"

  vars = {
    app_log_group_arn = "${aws_cloudwatch_log_group.app.arn}"
    ecs_log_group_arn = "${aws_cloudwatch_log_group.ecs.arn}"
  }
}

resource "aws_iam_role_policy" "instance" {
  name   = "TfEcsExampleInstanceRole"
  role   = "${aws_iam_role.app_instance.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}

## ALB

resource "aws_alb_target_group" "tg_web" {
  name     = "${var.service_name}-ecs-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  health_check {
    matcher = "200,302"
  }
}

resource "aws_alb" "main" {
  name            = "${var.service_name}-alb-ecs"
  internal        = false
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets         = "${data.terraform_remote_state.vpc.outputs.public_subnets}"
}

resource "aws_alb_listener" "front_end_web" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tg_web.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "front_end_api" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"

  certificate_arn = "${var.alb_ssl_certificate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.tg_web.arn}"
    type             = "forward"
  }
}

## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-group/ecs-agent-${var.service_name}"
}

resource "aws_cloudwatch_log_group" "app" {
  name = "ecs-group/app-${var.service_name}"
}

# ######################## Route 53 ##############################################

# resource "aws_route53_record" "alb_public_alias" {
#   zone_id = "${data.terraform_remote_state.vpc.public_host_zone}"
#   name = "${var.service_name}"
#   type = "${var.alb_public_alias_record_type}"
#   ttl = "${var.alb_public_alias_ttl}"
#   records = ["${aws_alb.main.dns_name}"]
# }

# resource "aws_route53_record" "alb_private_alias" {
#   zone_id = "${data.terraform_remote_state.vpc.private_host_zone}"
#   name = "${var.service_name}"
#   type = "${var.alb_public_alias_record_type}"
#   ttl = "${var.alb_public_alias_ttl}"
#   records = ["${aws_alb.main.dns_name}"]
# }