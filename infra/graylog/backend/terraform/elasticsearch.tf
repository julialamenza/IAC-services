######################## Security Group ########################################

resource "aws_security_group" "elastic" {
  name        = "sgp-${var.service_name}-elastic"
  description = "SG-${var.service_name}-elastic"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sgp-${var.service_name}-elastic"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

resource "aws_security_group_rule" "allow_db_from_bastion_elastic" {
    type = "ingress"
    from_port = "443"
    to_port = "443"
    protocol = "TCP"

    security_group_id = "${aws_security_group.elastic.id}"
    source_security_group_id = "${data.terraform_remote_state.vpc.outputs.sg_ssh_to_bastion}"
}

module "elasticsearch" {
  source                  = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git?ref=master"
  namespace               = "corum"
  stage                   = "prod"
  name                    = "graylog"
  security_groups         = ["${aws_security_group.elastic.id}"]
  vpc_id                  = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  subnet_ids              = "${slice(data.terraform_remote_state.vpc.outputs.private_subnets, 0, 2)}"
  zone_awareness_enabled  = "true"
  elasticsearch_version   = "6.5"
  instance_type           = "t2.small.elasticsearch"
  instance_count          = 2
  encrypt_at_rest_enabled = false
  kibana_subdomain_name   = "kibana-es"
  ebs_volume_size         = 35 
  create_iam_service_linked_role = false

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

output "elastic_sg" {
  value = "${aws_security_group.elastic.id}"
}