resource "aws_security_group" "allow_redis" {
  name        = "redis-sg"
  description = "Allow Redis inbound traffic"
  ingress {
    from_port   = 6379
    to_port     = 6379
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

resource "aws_memorydb_user" "admin" {
  user_name     = "admin"
  access_string = "on ~* &* +@all"

  authentication_mode {
    type      = "password"
    passwords = ["erwORTErEhERNIcu"]
  }
}

resource "aws_memorydb_acl" "redis_acl" {
  name       = "redis-acl"
  user_names = [aws_memorydb_user.admin.user_name]
}

resource "aws_memorydb_cluster" "redis_cluster" {
  acl_name                 = aws_memorydb_acl.redis_acl.name
  name                     = "distributed-atom-space"
  node_type                = "db.t4g.small"
  num_shards               = 1
  security_group_ids       = [aws_security_group.allow_redis.id]
  snapshot_retention_limit = 0
}
