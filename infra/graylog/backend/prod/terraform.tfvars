######################## Module variables ######################################

region                        = "eu-west-3"
env                           = "prod"

######################## Remote States vars ####################################

state_bucket                  = "bucket-name"
vpc_state_key                 = "vpc/prod"

######################## Instances vars ########################################

service_name                  = "graylog"
role                          = "database"

######################## ALB vars ##############################################

# alb_protocol_secure           = "HTTPS"
# alb_port_secure               = "443"
# alb_public_alias_record_type  = "CNAME"
# alb_public_alias_ttl          = "300"
# alb_private_alias_record_type = "CNAME"
# alb_ssl_certificate_id        = "arn:aws:acm:eu-west-1:249747140372:certificate/787449ee-25c9-4cc1-b4c4-74316d035cc4"


rds_username = "graylog"
rds_password = ""
rds_port = "5432"
rds_db_name = "sentry"
rds_engine = "postgres"
rds_version = "9.5.18"
rds_instance_class = "db.t2.large"
rds_allocated_storage = "200"
rds_major_engine_version = "9"
rds_family = "postgres9.5"