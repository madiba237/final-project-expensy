resource "aws_docdb_subnet_group" "docdb" {
  name       = "${var.cluster_name}-docdb-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.cluster_name}-docdb"
  engine                  = "docdb"
  master_username         = "expensy_admin"
  master_password         = var.docdb_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  skip_final_snapshot     = true
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = 1 # Augmenter à 2 pour de la haute disponibilité en production
  identifier         = "${var.cluster_name}-docdb-node-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}