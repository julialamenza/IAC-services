
# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = "${module.vpc.public_subnets}"
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = "${module.vpc.database_subnets}"
}
# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = "${module.vpc.nat_public_ips}"
}
############ vpc
output "vpc_azs" {
  value = "${var.vpc_azs}"
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "sg_ssh_from_bastion" {
  description = "Security group from bastion"
  value       = "${module.Bastion.sg_ssh_from_bastion}"
}

output "sg_ssh_to_bastion" {
  description = "Security group to bastion"
  value       = "${module.Bastion.sg_ssh_to_bastion}"
}


# # VPC endpoints
# output "vpc_endpoint_ssm_id" {
#   description = "The ID of VPC endpoint for SSM"
#   value       = "${module.vpc.vpc_endpoint_ssm_id}"
# }

# output "vpc_endpoint_ssm_network_interface_ids" {
#   description = "One or more network interfaces for the VPC Endpoint for SSM."
#   value       = ["${module.vpc.vpc_endpoint_ssm_network_interface_ids}"]
# }

# output "vpc_endpoint_ssm_dns_entry" {
#   description = "The DNS entries for the VPC Endpoint for SSM."
#   value       = ["${module.vpc.vpc_endpoint_ssm_dns_entry}"]
# }
