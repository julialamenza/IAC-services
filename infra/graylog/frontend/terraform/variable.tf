
variable "graylog_instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}
variable "key_name" {
  description = "Name of AWS key pair"
}
variable "region" {}
variable "env" {}

#Remote states vars
variable "state_bucket" {}

variable "vpc_state_key" {}

variable "backend_state_key" {}

# Web instances vars
variable "role" {}
variable "service_name" {}


# sg vars
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


