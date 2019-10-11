##############OUTPUT BASTION

output "sg_ssh_from_bastion" {
  value = "${aws_security_group.ssh_from_bastion.id}"
}

output "sg_ssh_to_bastion" {
  value = "${aws_security_group.ssh_to_bastion.id}"
}

output "sg_bastion" {
  value = "${aws_security_group.ssh_to_bastion.id}"
}

output "bastion_ip_address" {
  value = ["${aws_instance.bastion.*.public_ip}"]
}