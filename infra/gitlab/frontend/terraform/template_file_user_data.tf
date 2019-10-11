# Reference Teamcity server state file

data "template_file" "user_data_file" {
  template = "${file("../terraform/userdata.tpl")}"

  vars = {
    role        = "${var.role}"
    environment = "${var.env}"
    # self_fqdn   = "${aws_route53_record.alb_public_alias.fqdn}"
    device_name = "${var.ebs_device_name}"
  }
}
