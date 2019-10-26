locals {
  tags = "${merge(map(
    "Name", "${var.tags["service"]}-${var.tags["environment"]}"),
    var.tags
  )}"
  service = "${var.tags["service"]}"
  region = "${var.tags["region"]}"
  name = "${var.tags["service"]}-${var.tags["environment"]}"
  environment = "${var.tags["environment"]}"
}

resource "aws_elasticache_replication_group" "this" {
  automatic_failover_enabled    = true
  availability_zones            = ["${var.azs}"]
  replication_group_id          = "${lower( local.name )}"
  replication_group_description = "${lower( local.name )}"
  node_type                     = "${var.node_type}"
  number_cache_clusters         = "${length(var.azs)}"
  parameter_group_name          = "${var.parameter_group_name}"
  port                          = 6379
  engine                   = "redis"
  engine_version           = "${var.engine_version}"
  maintenance_window       = "${var.maintenance_window}"
  snapshot_window          = "${var.snapshot_window}"
  snapshot_retention_limit = "${var.snapshot_retention_limit}"
  subnet_group_name        = "${var.subnet_group}"
  security_group_ids            = ["${var.security_group_ids}"]
  apply_immediately        = "${var.apply_immediately}"
  tags = "${local.tags}"

  lifecycle {
    ignore_changes = ["number_cache_clusters"]
    create_before_destroy = true
  }
}

resource "aws_elasticache_cluster" "replica" {
  count = "${var.replica_count}"
  cluster_id           = "${lower( local.name )}-${count.index}"
  replication_group_id = "${aws_elasticache_replication_group.this.id}"
  tags = "${local.tags}"
}
