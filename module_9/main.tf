terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_m9" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_kms_key" "vpc_logs_kms_m9" {
  description             = "KMS key for S3 VPC flow logs bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "bucket_access_logs_m9" {
  bucket = "bucket-access-logs-m9"
}

resource "aws_s3_bucket_ownership_controls" "access_logs_ownership" {
  bucket = aws_s3_bucket.bucket_access_logs_m9.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_access_logs_m9_encryption" {
  bucket = aws_s3_bucket.bucket_access_logs_m9.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.vpc_logs_kms_m9.arn
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_logs_m9_encryption" {
  bucket = aws_s3_bucket.vpc_logs_bucket_m9.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.vpc_logs_kms_m9.arn
    }
  }
}

resource "aws_s3_bucket" "vpc_logs_bucket_m9" {
  bucket = "vpc-logs-bucket-m9"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_logs_encryption_m9" {
  bucket = aws_s3_bucket.vpc_logs_bucket_m9.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.vpc_logs_kms_m9.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "vpc_logs_versioning" {
  bucket = aws_s3_bucket.vpc_logs_bucket_m9.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "bucket_logs_versioning" {
  bucket = aws_s3_bucket.bucket_access_logs_m9.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "vpc_logs_logging" {
  bucket = aws_s3_bucket.vpc_logs_bucket_m9.id

  target_bucket = aws_s3_bucket.bucket_access_logs_m9.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_public_access_block" "vpc_logs_block_public_access" {
  bucket = aws_s3_bucket.vpc_logs_bucket_m9.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "access_logs_block_public_access" {
  bucket = aws_s3_bucket.bucket_access_logs_m9.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_flow_log" "flow_log_m9" {
  log_destination      = aws_s3_bucket.vpc_logs_bucket_m9.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc_m9.id
}

resource "aws_subnet" "subnet_m9" {
  vpc_id     = aws_vpc.vpc_m9.id
  cidr_block = "172.16.1.0/24"
}

module "create_ec2" {
  source = "./modules/create_ec2"

  subnet_id = aws_subnet.subnet_m9.id
  vpc_id    = aws_vpc.vpc_m9.id
  name      = var.name
}
