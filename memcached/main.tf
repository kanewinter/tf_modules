locals {
  tags = "${merge(map(
    "Name", "${var.tags["service"]}-${var.tags["environment"]}"),
    var.tags
  )}"
}

resource "aws_elasticache_cluster" "mem_this" {
  cluster_id           = "mem-${var.tags["service"]}-${var.tags["environment"]}"
  engine               = "${var.engine}"
  node_type            = "${var.node_type}"
  az_mode              = "${var.az_mode}"
  num_cache_nodes      = "${length(var.azs)}"
  parameter_group_name = "${var.parameter_group_name}"
  port                 = 11211
  tags                 = "${local.tags}"
}