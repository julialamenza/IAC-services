#################### Security Group ########################################


resource "aws_security_group_rule" "allow_alb_to_server" {
  type      = "ingress"
  from_port = "${var.instances_port}"
  to_port   = "${var.instances_port}"
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.graylog-ec2.id}"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group" "graylog-ec2" {
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
