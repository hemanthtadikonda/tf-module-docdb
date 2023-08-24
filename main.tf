resource "aws_docdb_subnet_group" "main" {
  name       = "${var.env}-docdb-subnets"
  subnet_ids = var.subnets
  tags       = merge(var.tags, { Name = "${var.env}-docdb-subnets" } )
}
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-docdb-cluster"
  engine                  = "${var.env}-docdb-cluster"
  master_username         = "foo"
  master_password         = "mustbeeightchars"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = var.subnets
  vpc_security_group_ids  = aws_security_group.main.id
}

resource "aws_security_group" "main" {
  name        = "${var.env}-docdb-sg"
  description = "${var.env}-docdb-subnets"
  vpc_id      = var.vpc_id
  tags        = merge (var.tags , { Name = "${var.env}-docdb-sg" }

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