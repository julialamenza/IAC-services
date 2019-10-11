output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.app.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.ecs_asg.id}"
}

output "elb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

# output "emq_public_hostname" {
#   value = "${aws_route53_record.alb_public_alias.fqdn}"
# }

# output "emq_private_hostname" {
#   value = "${aws_route53_record.alb_private_alias.fqdn}"
# }

output "repository_url" {
  value = "${aws_ecr_repository.ecs_repo.repository_url}"
}
