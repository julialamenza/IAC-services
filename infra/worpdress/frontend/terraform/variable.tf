variable "region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}

variable "env" {
  description = "The env to deploy"
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "3"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}

variable "service_name" {
  description = "Name of the service to deploy"
  default     = "emq"
}

variable "state_bucket" {
  description = "States Bucket (S3) name."
}

variable "vpc_state_key" {
  description = "States path (related to the state bucket) of the vpc"
}

variable "backend_state_key" {
  description = "States path (related to the state bucket) of the vpc"
}

variable "container_version" {
  description = "The version (tag) of the container to deploy"
  default = "latest"
}

variable "alb_public_alias_ttl"           { default = "300" }
variable "alb_public_alias_record_type"   { default = "CNAME" }
variable "alb_ssl_certificate_arn" {}
