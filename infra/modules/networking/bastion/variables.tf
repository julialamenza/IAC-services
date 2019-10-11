######### variables bastion

variable "bastion_trusted_networks" {
  default = ["0.0.0.0/0"]
}

variable "bastion_ssh_port" {
  default = "22"
}

variable "bastion_count" {
  default = 1
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_ami" {}
variable "bastion_key_name" {}

variable "vpc_id" {}

variable "public_subnets" {}

variable "bastion_name" {}
