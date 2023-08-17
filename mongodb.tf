resource "aws_security_group" "allow_mongodb" {
  name        = "mongodb-sg"
  description = "Allow Mongodb inbound traffic"
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "distributed-atom-space"
  engine                  = "docdb"
  master_username         = "das"
  master_password         = "bACheaKernom"
  backup_retention_period = 5
  availability_zones = [
    "us-east-1b",
    "us-east-1d",
    "us-east-1f",
  ]
  deletion_protection             = false
  enabled_cloudwatch_logs_exports = []
  storage_encrypted               = false
  vpc_security_group_ids = [
    aws_security_group.allow_mongodb.id,
  ]
  db_cluster_parameter_group_name = "default.docdb5.0"
  db_subnet_group_name            = "default"
  engine_version                  = "5.0.0"
  preferred_backup_window         = "03:26-03:56"
  preferred_maintenance_window    = "mon:06:47-mon:07:17"
  skip_final_snapshot             = true
}

resource "aws_docdb_cluster_instance" "docdbinstance" {
  count              = 1
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}
