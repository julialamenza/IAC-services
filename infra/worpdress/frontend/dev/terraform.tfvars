######################## Module variables ######################################

region                        = "eu-west-3"
env                           = "dev"
key_name                      = "corum-ux-dev"


######################## Remote States vars ####################################

state_bucket                  = "corum-ux-tfstates-dev"
vpc_state_key                 = "vpc/dev"
backend_state_key             = "wordpress/backend/dev"

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
alb_ssl_certificate_arn       = "arn:aws:acm:eu-west-3:558521238926:certificate/10b51203-bfef-4df9-b01c-524c0b324240"
