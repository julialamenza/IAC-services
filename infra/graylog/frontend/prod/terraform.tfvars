######################## Module variables ######################################

region                        = "eu-west-3"
env                           = "prod"
key_name                      = "key-name"


######################## Remote States vars ####################################

state_bucket                  = "bucket-name"
vpc_state_key                 = "vpc/prod"
backend_state_key             = "graylog/backend/prod"

######################## Instances vars ########################################

service_name                  = "graylog"
role                          = "server"
instance_type                 = "t3.medium"

######################## ALB vars ##############################################

alb_protocol_secure           = "HTTPS"
alb_port_secure               = "443"
alb_public_alias_record_type  = "CNAME"
alb_public_alias_ttl          = "300"
alb_private_alias_record_type = "CNAME"
alb_private_alias_ttl         = "300"
alb_ssl_certificate_arn       = "arn:aws:acm:eu-west-3:389278454829:certificate/8a9f93f6-be24-4042-8cb8-aa7a9d086c9a"
