output "address" {
  value = "${aws_elasticache_replication_group.this.primary_endpoint_address}"
}