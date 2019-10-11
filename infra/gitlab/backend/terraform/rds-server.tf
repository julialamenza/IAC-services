######################## Provider ##############################################

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

######################## Remote states #########################################

terraform {
  backend "s3" {}
  required_version = "0.12.3"
}

# Reference VPC state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.state_bucket}"
    key    = "${var.vpc_state_key}"
    region = "${var.region}"
  }
}

######################## Security Group ########################################

resource "aws_security_group" "database" {
  name        = "sgp-${var.service_name}-${var.role}"
  description = "SG-${var.service_name}-${var.role}"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sgp-${var.service_name}-${var.role}"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

resource "aws_security_group_rule" "allow_db_from_bastion" {
    type = "ingress"
    from_port = "${var.rds_port}"
    to_port = "${var.rds_port}"
    protocol = "TCP"

    security_group_id = "${aws_security_group.database.id}"
    source_security_group_id = "${data.terraform_remote_state.vpc.outputs.sg_ssh_from_bastion}"
}

# resource "aws_security_group_rule" "allow_alb_to_server" {
#   type      = "ingress"
#   from_port = "${var.instances_port}"
#   to_port   = "${var.instances_port}"
#   protocol  = "tcp"

#   security_group_id        = "${aws_security_group.drupal-server.id}"
#   source_security_group_id = "${aws_security_group.alb.id}"
# }


resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "rds-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

######################## RDS ########################################

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "${var.service_name}-database"

  engine            = "${var.rds_engine}"
  engine_version    = "${var.rds_version}"
  instance_class    = "${var.rds_instance_class}"
  allocated_storage = "${var.rds_allocated_storage}"

  name     = "${var.rds_db_name}"
  username = "${var.rds_username}"
  password = "${var.rds_password}"
  port     = "${var.rds_port}"

  major_engine_version = "${var.rds_major_engine_version}"

  iam_database_authentication_enabled = false

  family = "${var.rds_family}"

  vpc_security_group_ids = ["${aws_security_group.database.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_arn  = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Environment = "${var.env}"
  }

  # DB subnet group
  subnet_ids = "${data.terraform_remote_state.vpc.outputs.database_subnets}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.service_name}-final-snapshot"

  skip_final_snapshot = false

  # Database Deletion Protection
  deletion_protection = true

  # parameters = [
  #   {
  #     name = "character_set_client"
  #     value = "utf8"
  #   },
  #   {
  #     name = "character_set_server"
  #     value = "utf8"
  #   }
  # ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]
}

######################## Route 53 ##############################################

# resource "aws_route53_record" "alb_public_alias" {
#   zone_id = "${data.terraform_remote_state.vpc.outputs.public_host_zone}"
#   name    = "${var.service_name}"
#   type    = "${var.alb_public_alias_record_type}"
#   ttl     = "${var.alb_public_alias_ttl}"
#   records = ["${aws_alb.drupal-server.dns_name}"]
# }

######################## Module Outputs ########################################

# output "drupal_hostname" {
#   value = "${aws_route53_record.alb_public_alias.fqdn}"
# }

# output "drupal_srv_sg" {
#   value = "${aws_security_group.drupal-server.id}"
# }

# output "alb_sg" {
#   value = "${aws_security_group.alb.id}"
# }

output "rds_username" {
  value = "${module.db.this_db_instance_username}"
}

output "rds_password" {
  value = "${module.db.this_db_instance_password}"
}

output "rds_database" {
  value = "${module.db.this_db_instance_name}"
}

output "rds_port" {
  value = "${module.db.this_db_instance_port}"
}

output "rds_address" {
  value = "${module.db.this_db_instance_address}"
}