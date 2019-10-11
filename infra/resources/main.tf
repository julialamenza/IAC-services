############################ CALL MODULES ############################
provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

########################### CALL BASTION MODULE #####################

module "Bastion" {
  source = "../modules/networking/bastion/"
  bastion_name = "${var.bastion_name}" 
  bastion_ami = "${var.bastion_ami}"
  bastion_key_name = "${var.bastion_key_name}"
  vpc_id = "${module.vpc.vpc_id}"
  public_subnets = "${module.vpc.public_subnets}"
}
#######################################################################
######################### CALL VPC MODULE #############################

module "vpc" {
  source = "../modules/networking/vpc"

  namespace = "${var.namespace}"
  stage = "${var.stage}"

  vpc_cidr = "${var.vpc_cidr}"
  vpc_azs = "${var.vpc_azs}"
  vpc_private_subnets = "${var.vpc_private_subnets}"
  vpc_public_subnets = "${var.vpc_public_subnets}"
  vpc_database_subnets = "${var.vpc_database_subnets}"
}


#######################################################################