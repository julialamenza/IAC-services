
############################# ALB ##############################################

# Create web ELB security group

resource "aws_alb" "graylog-server" {
  name            = "alb-${var.service_name}-${var.role}"
  load_balancer_type = "network"
  subnets         = "${data.terraform_remote_state.vpc.outputs.public_subnets}"
  # security_groups = ["${aws_security_group.alb.id}"]

  tags = {
    Name        = "alb-${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}


resource "aws_alb_listener" "graylog-server-http" {
  load_balancer_arn = "${aws_alb.graylog-server.arn}"
  port              = "${var.alb_port}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.graylog-server-http.arn}"
    type             = "forward"
  }
}


resource "aws_alb_listener" "graylog-server-ssh" {
  load_balancer_arn = "${aws_alb.graylog-server.arn}"
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.graylog-server-ssh.arn}"
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
resource "aws_alb_target_group" "graylog-server-http" {
  name     = "tg-${var.service_name}-${var.role}-http-${random_id.target_group_name.hex}"
  port     = "${var.instances_port}"
  protocol = "TCP"
  vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    port                = "${var.instances_port_secure}"
    protocol            = "${var.instances_protocol_secure}"
    interval            = "10"
    path                = "/"
  }

  stickiness {
    enabled = false
    type = "lb_cookie"
  }
}

resource "aws_alb_target_group_attachment" "graylog-server-http" {
  target_group_arn = "${aws_alb_target_group.graylog-server-http.arn}"
  target_id        = "${aws_instance.graylog.id}"
  port             = "${var.instances_port}"
}

resource "aws_alb_target_group" "graylog-server-ssh" {
  name     = "tg-${var.service_name}-${var.role}-ssh-${random_id.target_group_name.hex}"
  port     = "22"
  protocol = "TCP"
  vpc_id   = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    port                = "${var.instances_port_secure}"
    protocol            = "${var.instances_protocol_secure}"
    interval            = "30"
    path                = "/"
  }

  stickiness {
    enabled = false
    type = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group_attachment" "graylog-server-ssh" {
  target_group_arn = "${aws_alb_target_group.graylog-server-ssh.arn}"
  target_id        = "${aws_instance.graylog.id}"
  port             = "22"
}