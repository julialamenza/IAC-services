######################## Module variables ######################################

region                        = "eu-west-3"
env                           = "staging"
key_name                      = "corum-ux-staging"


######################## Remote States vars ####################################

state_bucket                  = "corum-ux-tfstates-staging"
vpc_state_key                 = "vpc/staging"
backend_state_key             = "wordpress/backend/staging"

######################## Instances vars ########################################

service_name                  = "wordpress"
instance_type                 = "t3.medium"

######################## ALB vars ##############################################

alb_protocol_secure           = "HTTPS"
alb_port_secure               = "443"
alb_public_alias_record_type  = "CNAME"
alb_public_alias_ttl          = "300"
alb_private_alias_record_type = "CNAME"
alb_private_alias_ttl         = "300"
alb_ssl_certificate_arn       = "arn:aws:acm:eu-west-3:853534132268:certificate/ddef0ccb-db36-44ff-b3db-7c586aace726"
