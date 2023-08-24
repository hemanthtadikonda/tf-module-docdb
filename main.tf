resource "aws_docdb_subnet_group" "main" {
  name       = "${var.env}-docdb-subnet-grp"
  subnet_ids = var.subnets
  tags       = merge(var.tags, { Name = "${var.env}-docdb-subnet-grp" } )
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = var.family
  name        = "${var.env}-pg"
  description = "${var.env}-pg"
  tags       = merge(var.tags, { Name = "${var.env}-docdb-pg" } )

}


resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-docdb-cluster"
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.master_username.value
  master_password         = data.aws_ssm_parameter.master_password.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.main.id]
  tags       = merge(var.tags, { Name = "${var.env}-docdb-cluster" } )
  db_cluster_parameter_group_name =aws_docdb_cluster_parameter_group.main.name
}

resource "aws_security_group" "main" {
  name        = "${var.env}-docdb-sg"
  description = "${var.env}-docdb-sg"
  vpc_id      = var.vpc_id
  tags        = merge (var.tags , { Name = "${var.env}-docdb-sg" } )

  ingress {
    description      = "docdb"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.env}-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
}
