namespace = "namespace"
stage = "dev"
bastion_name = "bastion-dev"

vpc_cidr = "10.150.32.0/19"
vpc_azs = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
vpc_private_subnets = ["10.150.33.0/24", "10.150.34.0/24", "10.150.35.0/24"]
vpc_public_subnets = ["10.150.36.0/24", "10.150.37.0/24", "10.150.38.0/24"]
vpc_database_subnets = ["10.150.39.0/24", "10.150.40.0/24", "10.150.41.0/24"]

bastion_ami = "ami-0119667e27598718e"
bastion_key_name = "key-name"
