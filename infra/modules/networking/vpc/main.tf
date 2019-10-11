provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "default" {
  name   = "all"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg-allow-all-to-all"
  }
}

module "vpc_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "vpc"
  delimiter  = "-"
  tags       = "${map("BusinessUnit", "UX")}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${module.vpc_label.id}"

  cidr = "${var.vpc_cidr}"

  azs                 = "${var.vpc_azs}"
  private_subnet_suffix = "private"
  private_subnets     = "${var.vpc_private_subnets}"
  public_subnet_suffix = "public"
  public_subnets      = "${var.vpc_public_subnets}"
  database_subnet_suffix = "database"
  database_subnets    = "${var.vpc_database_subnets}"
  # elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24"]
  # redshift_subnets    = ["10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24"]
  # intra_subnets       = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = true
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = ["${aws_security_group.default.id}"]

  # VPC Endpoint for EC2MESSAGES
  enable_ec2messages_endpoint              = true
  ec2messages_endpoint_private_dns_enabled = true
  ec2messages_endpoint_security_group_ids  = ["${aws_security_group.default.id}"]

  # VPC Endpoint for ECR API
  enable_ecr_api_endpoint              = true
  ecr_api_endpoint_private_dns_enabled = true
  ecr_api_endpoint_security_group_ids  = ["${aws_security_group.default.id}"]

  # VPC Endpoint for ECR DKR
  enable_ecr_dkr_endpoint              = true
  ecr_dkr_endpoint_private_dns_enabled = true
  ecr_dkr_endpoint_security_group_ids  = ["${aws_security_group.default.id}"]

  # tags = "${module.vpc_label.tags}"
}