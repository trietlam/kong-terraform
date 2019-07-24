resource "aws_rds_cluster" "kong" {
  count              = "${var.db_instance_count > 0 ? 1 : 0}"
  cluster_identifier = "${var.service}-${var.environment}"
  engine             = "aurora-postgresql"
  master_username    = "${var.db_username}"
  master_password    = "${var.db_password}"

  backup_retention_period         = "${var.db_backup_retention_period}"
  db_subnet_group_name            = "${var.db_subnets}"
  db_cluster_parameter_group_name = "${var.service}-${var.environment}-cluster"

  vpc_security_group_ids = [
    "${aws_security_group.postgresql.id}",
  ]

  tags = "${merge(
    map("Name", format("%s-%s", var.service, var.environment)),
    map("Environment", var.environment),
    map("Description", var.description),
    map("Service", var.service),
    var.tags

  )}"
}

locals {
  kong_rds_cluster = "${aws_rds_cluster.kong[count.index]}"
}

resource "aws_rds_cluster_instance" "kong" {
  count              = "${var.db_instance_count}"
  identifier         = "${var.service}-${var.environment}-${count.index}"
  cluster_identifier = "${local.kong_rds_cluster.id}"
  engine             = "aurora-postgresql"
  instance_class     = "${var.db_instance_class}"

  db_subnet_group_name    = "${var.db_subnets}"
  db_parameter_group_name = "${var.service}-${var.environment}-instance"

  tags = "${merge(
    map("Name", format("%s-%s", var.service, var.environment)),
    map("Environment", var.environment),
    map("Description", var.description),
    map("Service", var.service),
    var.tags
  )}"
}

resource "aws_rds_cluster_parameter_group" "kong" {
  count  = "${var.db_instance_count > 0 ? 1 : 0}"
  name   = "${var.service}-${var.environment}-cluster"
  family = "aurora-postgresql9.6"

  description = "${var.description}"

  tags = "${merge(
    map("Name", format("%s-%s-cluster", var.service, var.environment)),
    map("Environment", var.environment),
    map("Description", var.description),
    map("Service", var.service),
    var.tags
  )}"
}

resource "aws_db_parameter_group" "kong" {
  count  = "${var.db_instance_count > 0 ? 1 : 0}"
  name   = "${var.service}-${var.environment}-instance"
  family = "aurora-postgresql9.6"

  description = "${var.description}"

  tags = "${merge(
    map("Name", format("%s-%s-instance", var.service, var.environment)),
    map("Environment", var.environment),
    map("Description", var.description),
    map("Service", var.service),
    var.tags
  )}"
}
