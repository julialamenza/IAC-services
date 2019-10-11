######################### Security Group #######################################

resource "aws_security_group" "ssh_to_bastion" {
  name        = "sgp-allow-ssh-to-bastion"
  description = "Allow remote ssh from trusted networks"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.bastion_ssh_port}"
    to_port     = "${var.bastion_ssh_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.bastion_trusted_networks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgp-allow-ssh-to-bastion"
  }
}

resource "aws_security_group" "ssh_from_bastion" {
  name        = "sgp-allow-ssh-from-bastion"
  description = "Allow all ssh from remote bastion servers"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = "${var.bastion_ssh_port}"
    to_port         = "${var.bastion_ssh_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh_to_bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgp-allow-ssh-from-bastion"
  }
}

######################### EC2 ##################################################

resource "aws_instance" "bastion" {
  count                  = "${var.bastion_count}"
  ami                    = "${var.bastion_ami}"
  instance_type          = "${var.bastion_instance_type}"
  key_name               = "${var.bastion_key_name}"
  subnet_id              = "${element(var.public_subnets, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.ssh_to_bastion.id}"]

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.bastion_name}"
  }
}
