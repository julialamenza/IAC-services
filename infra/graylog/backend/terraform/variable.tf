######################## Module variables ######################################

variable "region" {}
variable "env" {}

#Remote states vars
variable "state_bucket" {}

variable "vpc_state_key" {}

# Web instances vars
variable "role" {}
variable "service_name" {}

# variable "alb_ssl_certificate_id" {}

######################## MongoDB ######################################

variable "mongo_ami" {
  default = "ami-0f0ec9a05c7457258"
}

variable "key_name" {
  default = "corum-ux-prod"
}

variable "ebs_type" {
  default = "gp2"
}

variable "ebs_size" {
  default = 200
}

variable "ebs_device_name" {
  default = "/dev/xvdh"
}
