namespace = "namespace"
stage = "staging"
bastion_name = "bastion-staging"


vpc_cidr = "10.150.64.0/19"
vpc_azs = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
vpc_private_subnets = ["10.150.65.0/24", "10.150.66.0/24", "10.150.67.0/24"]
vpc_public_subnets = ["10.150.68.0/24", "10.150.69.0/24", "10.150.70.0/24"]
vpc_database_subnets = ["10.150.71.0/24", "10.150.72.0/24", "10.150.73.0/24"]

bastion_ami = "ami-0119667e27598718e"
bastion_key_name = "key-name"
