namespace = "namespace"
stage = "prod"
bastion_name = "bastion-prod"


vpc_cidr = "10.150.0.0/19"
vpc_azs = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
vpc_private_subnets = ["10.150.1.0/24", "10.150.2.0/24", "10.150.3.0/24"]
vpc_public_subnets = ["10.150.4.0/24", "10.150.5.0/24", "10.150.6.0/24"]
vpc_database_subnets = ["10.150.7.0/24", "10.150.8.0/24", "10.150.9.0/24"]

bastion_ami = "ami-0119667e27598718e"
bastion_key_name = "key-name"
