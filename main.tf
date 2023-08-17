terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_ecr_repository" "das" {
  name                 = "das"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_s3_bucket" "das" {
  bucket = "das.functions.singularitynet.io"
  tags = {
    Name        = "env"
    Environment = "Prod"
  }
}

resource "aws_s3_object" "function_folder" {
    bucket = "${aws_s3_bucket.das.id}"
    acl    = "private"
    key    = "getAllDataFunction/"
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "das-entire-bucket" {
  bucket = aws_s3_bucket.das.id
  name   = "EntireBucket"

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 125
  }
}

output "aws_ecr_link" {
  value = aws_ecr_repository.das.repository_url
}
