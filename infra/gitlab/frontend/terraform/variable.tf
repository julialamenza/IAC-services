######################## Module variables ######################################

variable "region" {}
variable "env" {}

#Remote states vars
variable "state_bucket" {}

variable "vpc_state_key" {}

variable "backend_state_key" {}

# Web instances vars
variable "role" {}

variable "instance_type" {}
variable "ami_id" {}
variable "service_name" {}
variable "key_name" {}

variable "instances_protocol" {
  default = "HTTP"
}

variable "instances_port" {
  default = "80"
}

variable "instances_protocol_secure" {
  default = "HTTP"
}

variable "instances_port_secure" {
  default = "80"
}

variable "ebs_type" {
  default = "gp2"
}

variable "ebs_size" {
  default = 100
}

variable "ebs_device_name" {
  default = "/dev/xvdh"
}

# ALB vars
variable "alb_protocol" {
  default = "HTTP"
}

variable "alb_port" {
  default = "80"
}

variable "alb_protocol_secure" {
  default = "HTTPS"
}

variable "alb_port_secure" {
  default = "443"
}

# variable "alb_ssl_certificate_id" {}

variable "alb_public_alias_ttl" {
  default = "300"
}

variable "alb_public_alias_record_type" {
  default = "CNAME"
}
