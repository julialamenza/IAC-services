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

######################## RDS ######################################

variable "rds_username" {
  description = "The username of the rds database"
}

variable "rds_password" {
  description = "The password of the rds database"
}

variable "rds_port" {
  description = "The port of the rds database"
}

variable "rds_db_name" {
  description = "The database name of the rds database"
}

variable "rds_engine" {
  description = "The type of the rds database"
  default = "mysql"
}

variable "rds_version" {
  description = "The major version of the rds database"
  default = "5.7.22"
}

variable "rds_instance_class" {
  description = "The instance class of the rds database"
  default = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "The instance class of the rds database"
  default = "20"
}

variable "rds_major_engine_version" {
  description = "The major engine version of the rds database"
  default = "5.7"
}

variable "rds_family" {
  description = "The DB parameter group of the rds database"
  default = "mysql5.7"
}