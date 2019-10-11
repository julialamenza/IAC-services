// Generate a random string for auth token, no special chars
resource "random_string" "auth_token" {
  length = 64
  special = false
}

resource "aws_security_group" "redis" {
  name        = "sgp-${var.service_name}-redis"
  description = "SG-${var.service_name}-redis"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sgp-${var.service_name}-redis"
    Service     = "${var.service_name}"
    Environment = "${var.env}"
    Role        = "${var.role}"
  }
}

module "redis" {
  source          = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=master"
  namespace       = "eg"
  stage           = "dev"
  name            = "redis"
  security_groups = ["${aws_security_group.redis.id}"]

  vpc_id                       = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  subnets                      = "${data.terraform_remote_state.vpc.outputs.database_subnets}"
  maintenance_window           = "wed:03:00-wed:04:00"
  instance_type                = "cache.t2.micro"
  engine_version               = "4.0.10"
  apply_immediately            = true
  availability_zones           = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  automatic_failover           = false
  at_rest_encryption_enabled   = false
  transit_encryption_enabled   = false
}

output "redis_auth_token" {
  value = random_string.auth_token.result
}

output "redis_host" {
  value = "${module.redis.host}"
}

output "redis_sg" {
    value = "${aws_security_group.redis.id}"
}