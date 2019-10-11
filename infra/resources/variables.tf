variable "region" {
  description = "The region of the stack"
  default     = "eu-west-3"
}

variable "namespace" {
  description = "The namespace of the stack"
  default     = "corum-ux"
}

variable "stage" {
  description = "The stage of the stack"
}

###################### vpc variable
variable "vpc_cidr" {
  description = "The CIDR of VPC"
}

variable "vpc_azs" {
  type    = "list"
  default = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "vpc_private_subnets" {
  type    = "list"
}

variable "vpc_public_subnets" {
  type    = "list"
}

variable "vpc_database_subnets" {
  type    = "list"
}


################# Bastion Variables
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
variable "bastion_name" {}
