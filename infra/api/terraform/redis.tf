module "redis" {
  source         = "github.com/terraform-community-modules/tf_aws_elasticache_redis?ref=v1.3.0"
  env            = "${var.env}"
  name           = "thtest"
  redis_clusters = "2"
  redis_failover = "true"
  subnets        = "${module.vpc.database_subnets}"
  vpc_id         = "${module.vpc.vpc_id}"
}