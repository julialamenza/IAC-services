
output "graylog_port" {
  value = "${var.alb_port_secure}"
}

output "graylog_srv_sg" {
  value = "${aws_security_group.graylog-ec2.id}"
}