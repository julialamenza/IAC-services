######################## Module variables ######################################

region                        = "eu-west-3"
env                           = "prod"
key_name                      = "key-name"

######################## Remote States vars ####################################

state_bucket                  = "bucket-name"
vpc_state_key                 = "vpc/prod"
backend_state_key             = "gitlab/backend/prod"

######################## Instances vars ########################################

service_name                  = "gitlab"
role                          = "server"
instance_type                 = "t3.medium"

######################## ALB vars ##############################################

alb_protocol_secure           = "HTTPS"
alb_port_secure               = "443"
alb_public_alias_record_type  = "CNAME"
alb_public_alias_ttl          = "300"
alb_private_alias_record_type = "CNAME"
alb_private_alias_ttl         = "300"
# alb_ssl_certificate_id        = "arn:aws:acm:eu-west-1:249747140372:certificate/787449ee-25c9-4cc1-b4c4-74316d035cc4"
