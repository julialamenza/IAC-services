resource "aws_security_group_rule" "sgr_rds" {
  type                     = "ingress"        # e.g. ingress
  from_port                = "${data.terraform_remote_state.backend.outputs.rds_port}"   # e.g. 80
  to_port                  = "${data.terraform_remote_state.backend.outputs.rds_port}"     # e.g. 80
  protocol                 = "tcp"    # e.g. tcp

  security_group_id        = "${data.terraform_remote_state.backend.outputs.rds_sg}"   # e.g. redis_sg
  source_security_group_id = "${aws_security_group.instance_sg.id}"   # e.g. web_sg
}

resource "aws_security_group_rule" "sgr_redis" {
  type                     = "ingress"        # e.g. ingress
  from_port                = "6379"   # e.g. 80
  to_port                  = "6379"     # e.g. 80
  protocol                 = "tcp"    # e.g. tcp

  security_group_id        = "${data.terraform_remote_state.backend.outputs.redis_sg}"   # e.g. redis_sg
  source_security_group_id = "${aws_security_group.instance_sg.id}"   # e.g. web_sg
}